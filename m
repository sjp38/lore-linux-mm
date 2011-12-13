Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 741FD6B025B
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 08:59:16 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so6250298vbb.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 05:59:15 -0800 (PST)
Message-ID: <1323784748.2950.4.camel@edumazet-laptop>
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory
 pressure controls
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Dec 2011 14:59:08 +0100
In-Reply-To: <4EE757D7.6060006@uclouvain.be>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>
	 <20111212.190734.1967808916779299221.davem@davemloft.net>
	 <4EE757D7.6060006@uclouvain.be>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christoph.paasch@uclouvain.be
Cc: David Miller <davem@davemloft.net>, glommer@parallels.com, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, cgroups@vger.kernel.org

Le mardi 13 dA(C)cembre 2011 A  14:49 +0100, Christoph Paasch a A(C)crit :

> now there are plenty of compiler-warnings when CONFIG_CGROUPS is not set:
> 
> In file included from include/linux/tcp.h:211:0,
>                  from include/linux/ipv6.h:221,
>                  from include/net/ip_vs.h:23,
>                  from kernel/sysctl_binary.c:6:
> include/net/sock.h:67:57: warning: a??struct cgroup_subsysa?? declared
> inside parameter list [enabled by default]
> include/net/sock.h:67:57: warning: its scope is only this definition or
> declaration, which is probably not what you want [enabled by default]
> include/net/sock.h:67:57: warning: a??struct cgroupa?? declared inside
> parameter list [enabled by default]
> include/net/sock.h:68:61: warning: a??struct cgroup_subsysa?? declared
> inside parameter list [enabled by default]
> include/net/sock.h:68:61: warning: a??struct cgroupa?? declared inside
> parameter list [enabled by default]
> 
> 
> Because struct cgroup is only declared if CONFIG_CGROUPS is enabled.
> (cfr. linux/cgroup.h)
> 

Yes, we probably need forward reference like this :

Thanks !

[PATCH net-next] net: fix build error if CONFIG_CGROUPS=n

Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 18ecc99..6fe0dae 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -64,6 +64,8 @@
 #include <net/dst.h>
 #include <net/checksum.h>
 
+struct cgroup;
+struct cgroup_subsys;
 int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *ss);
 void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss);
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
