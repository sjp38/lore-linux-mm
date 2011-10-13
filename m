Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 497B16B002F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 09:11:06 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
Date: Thu, 13 Oct 2011 17:09:34 +0400
Message-Id: <1318511382-31051-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

Hi Andrew,

This series was extensively reviewed over the past month, and after
all major comments were merged, I feel it is ready for inclusion when
the next merge window opens. Minor fixes will be provided if they
prove to be necessary.

You can see the most recent past discussions at:

https://lkml.org/lkml/2011/10/10/116
https://lkml.org/lkml/2011/10/4/116
https://lkml.org/lkml/2011/10/3/133

It basically lays the foundation for kernel memory limitation as a
general framework, and uses it to control the existent tcp memory pressure
thresholds in a per-cgroup way.

Follow up patches are expected for soft limits, which are not handled.

Please consider this for inclusion in your tree

Thanks,

Glauber Costa (8):
  Basic kernel memory functionality for the Memory Controller
  socket: initial cgroup code.
  foundations of per-cgroup memory pressure controlling.
  per-cgroup tcp buffers control
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Disable task moving when using kernel memory accounting

 Documentation/cgroups/memory.txt |   38 ++++-
 crypto/af_alg.c                  |    8 +-
 include/linux/memcontrol.h       |   49 +++++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  130 +++++++++++++-
 include/net/tcp.h                |   30 +++-
 include/net/udp.h                |    4 +-
 include/trace/events/sock.h      |   10 +-
 init/Kconfig                     |   14 ++
 mm/memcontrol.c                  |  373 ++++++++++++++++++++++++++++++++++++--
 net/core/sock.c                  |  104 ++++++++---
 net/decnet/af_decnet.c           |   22 ++-
 net/ipv4/proc.c                  |    7 +-
 net/ipv4/sysctl_net_ipv4.c       |   71 +++++++-
 net/ipv4/tcp.c                   |   60 ++++---
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   23 ++-
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv4/udp.c                   |   21 ++-
 net/ipv6/tcp_ipv6.c              |   20 ++-
 net/ipv6/udp.c                   |    4 +-
 net/sctp/socket.c                |   37 +++-
 23 files changed, 910 insertions(+), 132 deletions(-)

-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
