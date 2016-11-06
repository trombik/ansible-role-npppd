# ansible-role-npppd

Configure OpenBSD's [npppd(8)](http://man.openbsd.org/npppd.8).

# Requirements

Only supported platform is OpenBSD.

# Role Variables

The role dose not yet support all configurations found in
[npppd.conf(5)](http://man.openbsd.org/npppd.conf.5).

| Variable | Description | Default |
|----------|-------------|---------|
| npppd\_user | user name of the daemon | \_npppd |
| npppd\_group | group name of the daemon | \_npppd |
| npppd\_conf\_dir | dir of config files | /etc/npppd |
| npppd\_service | the service name | npppd |
| npppd\_conf | path to npppd.conf | {{ npppd\_conf\_dir }}/npppd.conf |
| npppd\_users\_file | the path to npppd-users | {{ npppd\_conf\_dir }}/npppd-users |
| npppd\_flags | | "" |
| npppd\_users | a dict of ppp users that is used by local authentication | {} |
| npppd\_tunnel | a dict of tunnels | {} |
| npppd\_ipcp | a dict of ipcp | {} |
| npppd\_interface | a dict of interfaces | {} |
| npppd\_authentication | a dict of authentications | {} |
| npppd\_bind | bind tunnel, authentication, and interface | [] |

## npppd\_tunnel

the tunnel for PPP.

    npppd_tunnel:
      l2tp_tunnel:
        protocol: l2tp
        options:
          - "listen_on {{ ansible_default_ipv4.address }}"

## npppd\_interface

a dict of interface configuration.

    npppd_interface:
      pppx0:
        address: 192.168.100.254
        ipcp: ipcp1
      pppx1:
        address: 192.168.200.254
        ipcp: ipcp2

## npppd\_ipcp

a dict of ipcp.

    npppd_ipcp:
      ipcp1:
        - pool-address 192.168.100.1-192.168.100.250
        - dns-servers 8.8.8.8
      ipcp2:
        - pool-address 192.168.200.1-192.168.200.250
        - dns-servers 8.8.8.8

## npppd\_authentication

This valiable is a dict of name of authetication method. Name can be arbitary.
The value of the key is a dict of configuration.

| key | value |
|-----|-------|
| type | `radius` or `local` |
| options | array of lines of configurations for the authentication (optional) |

### type: local

When type is `local`, `users-file` key must exist. the value should be path to
[npppd-users(5)](http://man.openbsd.org/npppd-users.5).

    npppd_authentication:
      LOCAL:
        type: local
        options:
          - users-file "{{ npppd_users_file }}"

### type: radius

When type is `radius`, `servers` key must exist. The value is a dict of servers.

| key | value |
|-----|-------|
| port | port number of radius (optional) |
| secret | password for radius |
| options | array of lines of configurations for the server (optional) |

```yaml
npppd_authentication:
  RADIUS:
    type: radius
    options:
      - strip-nt-domain no
    servers:
      127.0.0.1:
        port: 1812
        secret: password
        options:
          - timeout 10
      server2.example.org:
        port: 1812
        secret: password
        options:
          - timeout 10
```

## npppd\_bind

`npppd_bind` binds tunnel, authetication, and interface

```yaml
npppd_bind:
  -
    from: l2tp_tunnel
    authenticated_by: LOCAL
    to: pppx0
```

# Dependencies

None

# Example Playbook

See [npppd.conf(5)](http://man.openbsd.org/npppd.conf.5).

## Simple L2TP configuration

```yaml
- hosts: localhost
  roles:
    - ansible-role-npppd
  vars:
    npppd_tunnel:
      l2tp_tunnel:
        protocol: l2tp
        options:
          - "listen on {{ ansible_default_ipv4.address }}"
          - "lcp-keepalive yes"
          - "tcp-mss-adjust yes"
    npppd_ipcp:
      ipcp1:
        - pool-address 192.168.100.1-192.168.100.250
        - dns-servers 8.8.8.8
    npppd_interface:
      pppx0:
        address: 192.168.100.254
        ipcp: ipcp1
    npppd_authentication:
      LOCAL:
        type: local
        options:
          - 'users-file "{{ npppd_users_file }}"'
    npppd_bind:
      -
        from: l2tp_tunnel
        authenticated_by: LOCAL
        to: pppx0

    npppd_users:
      foo:
        password: 'password:\^'
      bar-:
        password: password
        framed-ip-address: 192.168.100.1
      buz_:
        password: password
        framed-ip-network: 192.168.101.0/24
```

## Same but authenticates users by RADIUS

```yaml
- hosts: localhost
  roles:
    - ansible-role-npppd
  vars:
    npppd_tunnel:
      l2tp_tunnel:
        protocol: l2tp
        options:
          - "listen on {{ ansible_default_ipv4.address }}"
    npppd_ipcp:
      ipcp1:
        - pool-address 192.168.100.1-192.168.100.250
        - dns-servers 8.8.8.8
    npppd_interface:
      pppx0:
        address: 192.168.100.254
        ipcp: ipcp1
    npppd_authentication:
      RADIUS:
        type: radius
        options:
          - strip-nt-domain no
        servers:
          127.0.0.1:
            port: 1812
            secret: password
            options:
              - timeout 10
    npppd_bind:
      -
        from: l2tp_tunnel
        authenticated_by: RADIUS
        to: pppx0
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [ansible-role-init](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
