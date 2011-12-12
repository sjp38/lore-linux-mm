Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E1CC36B00C0
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 02:48:26 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory pressure controls
Date: Mon, 12 Dec 2011 11:47:00 +0400
Message-Id: <1323676029-5890-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

Hi,

This series fixes all the few comments raised in the last round,
and seem to have acquired consensus from the memcg side.

Dave, do you think it is acceptable now from the networking PoV?
In case positive, would you prefer merging this trough your tree,
or acking this so a cgroup maintainer can do it?


Thanks

Glauber Costa (9):
  Basic kernel memory functionality for the Memory Controller
  foundations of per-cgroup memory pressure controlling.
  socket: initial cgroup code.
  tcp memory pressure controls
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Display current tcp failcnt in kmem cgroup
  Display maximum tcp memory allocation in kmem cgroup

 Documentation/cgroups/memory.txt |   46 ++++++-
 include/linux/memcontrol.h       |   23 ++++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  244 +++++++++++++++++++++++++++++++++-
 include/net/tcp.h                |    4 +-
 include/net/tcp_memcontrol.h     |   19 +++
 init/Kconfig                     |   11 ++
 mm/memcontrol.c                  |  191 +++++++++++++++++++++++++-
 net/core/sock.c                  |  112 ++++++++++++----
 net/ipv4/Makefile                |    1 +
 net/ipv4/af_inet.c               |    2 +
 net/ipv4/proc.c                  |    6 +-
 net/ipv4/sysctl_net_ipv4.c       |   65 ++++++++-
 net/ipv4/tcp.c                   |   11 +--
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   14 ++-
 net/ipv4/tcp_memcontrol.c        |  272 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv6/af_inet6.c              |    2 +
 net/ipv6/tcp_ipv6.c              |    8 +-
 21 files changed, 973 insertions(+), 75 deletions(-)
 create mode 100644 include/net/tcp_memcontrol.h
 create mode 100644 net/ipv4/tcp_memcontrol.c

-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
