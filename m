Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 606006B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 19:00:22 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v7 00/10] Request for Inclusion: per-cgroup tcp memory pressure 
Date: Tue, 29 Nov 2011 21:56:51 -0200
Message-Id: <1322611021-1730-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

Hi,

This patchset implements per-cgroup tcp memory pressure controls. It did not change
significantly since last submission: rather, it just merges the comments Kame had.
Most of them are style-related and/or Documentation, but there are two real bugs he
managed to spot (thanks)

Please let me know if there is anything else I should address.


Glauber Costa (10):
  Basic kernel memory functionality for the Memory Controller
  foundations of per-cgroup memory pressure controlling.
  socket: initial cgroup code.
  tcp memory pressure controls
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Display current tcp failcnt in kmem cgroup
  Display maximum tcp memory allocation in kmem cgroup
  Disable task moving when using kernel memory accounting

 Documentation/cgroups/memory.txt |   52 +++++++-
 include/linux/memcontrol.h       |   19 +++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  298 +++++++++++++++++++++++++++++++++++++-
 include/net/tcp.h                |    4 +-
 include/net/tcp_memcontrol.h     |   19 +++
 init/Kconfig                     |   14 ++
 mm/memcontrol.c                  |  202 ++++++++++++++++++++++++--
 net/core/sock.c                  |  120 +++++++++++----
 net/ipv4/Makefile                |    1 +
 net/ipv4/af_inet.c               |    2 +
 net/ipv4/proc.c                  |    7 +-
 net/ipv4/sysctl_net_ipv4.c       |   65 ++++++++-
 net/ipv4/tcp.c                   |   11 +-
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   13 +-
 net/ipv4/tcp_memcontrol.c        |  268 ++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv6/af_inet6.c              |    2 +
 net/ipv6/tcp_ipv6.c              |    7 +-
 21 files changed, 1036 insertions(+), 85 deletions(-)
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
