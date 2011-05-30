Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 863A36B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 22:30:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 96FAB3EE0B6
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:30:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 773A645DEA0
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:30:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E66B45DE9E
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:30:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ED101DB8037
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:30:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 018211DB803F
	for <linux-mm@kvack.org>; Mon, 30 May 2011 11:30:45 +0900 (JST)
Date: Mon, 30 May 2011 11:23:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Fwd: cgroup OOM killer loop causes system to lockup (possible
 fix included)
Message-Id: <20110530112355.e92a58c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4DE2C787.1050809@simplicitymedialtd.co.uk>
References: <4DE2BFA2.3030309@simplicitymedialtd.co.uk>
	<4DE2C787.1050809@simplicitymedialtd.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Cal Leeming [Simplicity Media Ltd]" <cal.leeming@simplicitymedialtd.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>


Thank you. memory cgroup and OOM troubles are handled in linux-mm.

On Sun, 29 May 2011 23:24:07 +0100
"Cal Leeming [Simplicity Media Ltd]"  <cal.leeming@simplicitymedialtd.co.uk> wrote:

> Some further logs:
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369927] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369939]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399285] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399296]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428690] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428702]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487696] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487708]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517023] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517035]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546379] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546391]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310789] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310804]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369918] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369930]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399284] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399296]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433634] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433648]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463947] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463959]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493439] redis-server 
> invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493451]  
> [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> 
> 

hmm, in short, applications has -17 oom_adj in default with 2.6.32.41 ?
AFAIK, no kernel has such crazy settings as default..

Does your 2 kernel uses the same environment/distribution ?

Thanks,
-Kame

> On 29/05/2011 22:50, Cal Leeming [Simplicity Media Ltd] wrote:
> >  First of all, my apologies if I have submitted this problem to the 
> > wrong place, spent 20 minutes trying to figure out where it needs to 
> > be sent, and was still none the wiser.
> >
> > The problem is related to applying memory limitations within a cgroup. 
> > If the OOM killer kicks in, it gets stuck in a loop where it tries to 
> > kill a process which has an oom_adj of -17. This causes an infinite 
> > loop, which in turn locks up the system.
> >
> > May 30 03:13:08 vicky kernel: [ 1578.117055] Memory cgroup out of 
> > memory: kill process 6016 (java) score 0 or a child
> > May 30 03:13:08 vicky kernel: [ 1578.117154] Memory cgroup out of 
> > memory: kill process 6016 (java) score 0 or a child
> > May 30 03:13:08 vicky kernel: [ 1578.117248] Memory cgroup out of 
> > memory: kill process 6016 (java) score 0 or a child
> > May 30 03:13:08 vicky kernel: [ 1578.117343] Memory cgroup out of 
> > memory: kill process 6016 (java) score 0 or a child
> > May 30 03:13:08 vicky kernel: [ 1578.117441] Memory cgroup out of 
> > memory: kill process 6016 (java) score 0 or a child
> >
> >
> >  root@vicky [/home/foxx] > uname -a
> > Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x86_64 
> > GNU/Linux
> > (this happens on both the grsec patched and non patched 2.6.32.41 kernel)
> >
> > When this is encountered, the memory usage across the whole server is 
> > still within limits (not even hitting swap).
> >
> > The memory configuration for the cgroup/lxc is:
> > lxc.cgroup.memory.limit_in_bytes = 3000M
> > lxc.cgroup.memory.memsw.limit_in_bytes = 3128M
> >
> > Now, what is even more strange, is that when running under the 
> > 2.6.32.28 kernel (both patched and unpatched), this problem doesn't 
> > happen. However, there is a slight difference between the two kernels. 
> > The 2.6.32.28 kernel gives a default of 0 in the /proc/X/oom_adj, 
> > where as the 2.6.32.41 gives a default of -17. I suspect this is the 
> > root cause of why it's showing in the later kernel, but not the earlier.
> >
> > To test this theory, I started up the lxc on both servers, and then 
> > ran a one liner which showed me all the processes with an oom_adj of -17:
> >
> > (the below is the older/working kernel)
> > root@courtney.internal [/mnt/encstore/lxc] > uname -a
> > Linux courtney.internal 2.6.32.28-grsec #3 SMP Fri Feb 18 16:09:07 GMT 
> > 2011 x86_64 GNU/Linux
> > root@courtney.internal [/mnt/encstore/lxc] > for x in `find /proc 
> > -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print $3}'` ; do 
> > ps -p $x --no-headers ; done
> > grep: /proc/1411/task/1411/oom_adj: No such file or directory
> > grep: /proc/1411/oom_adj: No such file or directory
> >   804 ?        00:00:00 udevd
> >   804 ?        00:00:00 udevd
> > 25536 ?        00:00:00 sshd
> > 25536 ?        00:00:00 sshd
> > 31861 ?        00:00:00 sshd
> > 31861 ?        00:00:00 sshd
> > 32173 ?        00:00:00 udevd
> > 32173 ?        00:00:00 udevd
> > 32174 ?        00:00:00 udevd
> > 32174 ?        00:00:00 udevd
> >
> > (the below is the newer/broken kernel)
> >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > uname -a
> > Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x86_64 
> > GNU/Linux
> >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > for x in 
> > `find /proc -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print 
> > $3}'` ; do ps -p $x --no-headers ; done
> > grep: /proc/3118/task/3118/oom_adj: No such file or directory
> > grep: /proc/3118/oom_adj: No such file or directory
> >   895 ?        00:00:00 udevd
> >   895 ?        00:00:00 udevd
> >  1091 ?        00:00:00 udevd
> >  1091 ?        00:00:00 udevd
> >  1092 ?        00:00:00 udevd
> >  1092 ?        00:00:00 udevd
> >  2596 ?        00:00:00 sshd
> >  2596 ?        00:00:00 sshd
> >  2608 ?        00:00:00 sshd
> >  2608 ?        00:00:00 sshd
> >  2613 ?        00:00:00 sshd
> >  2613 ?        00:00:00 sshd
> >  2614 pts/0    00:00:00 bash
> >  2614 pts/0    00:00:00 bash
> >  2620 pts/0    00:00:00 sudo
> >  2620 pts/0    00:00:00 sudo
> >  2621 pts/0    00:00:00 su
> >  2621 pts/0    00:00:00 su
> >  2622 pts/0    00:00:00 bash
> >  2622 pts/0    00:00:00 bash
> >  2685 ?        00:00:00 lxc-start
> >  2685 ?        00:00:00 lxc-start
> >  2699 ?        00:00:00 init
> >  2699 ?        00:00:00 init
> >  2939 ?        00:00:00 rc
> >  2939 ?        00:00:00 rc
> >  2942 ?        00:00:00 startpar
> >  2942 ?        00:00:00 startpar
> >  2964 ?        00:00:00 rsyslogd
> >  2964 ?        00:00:00 rsyslogd
> >  2964 ?        00:00:00 rsyslogd
> >  2964 ?        00:00:00 rsyslogd
> >  2980 ?        00:00:00 startpar
> >  2980 ?        00:00:00 startpar
> >  2981 ?        00:00:00 ctlscript.sh
> >  2981 ?        00:00:00 ctlscript.sh
> >  3016 ?        00:00:00 cron
> >  3016 ?        00:00:00 cron
> >  3025 ?        00:00:00 mysqld_safe
> >  3025 ?        00:00:00 mysqld_safe
> >  3032 ?        00:00:00 sshd
> >  3032 ?        00:00:00 sshd
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3097 ?        00:00:00 mysqld.bin
> >  3113 ?        00:00:00 ctl.sh
> >  3113 ?        00:00:00 ctl.sh
> >  3115 ?        00:00:00 sleep
> >  3115 ?        00:00:00 sleep
> >  3116 ?        00:00:00 .memcached.bin
> >  3116 ?        00:00:00 .memcached.bin
> >
> >
> > As you can see, it is clear that the newer kernel is setting -17 by 
> > default, which in turn is causing the OOM killer loop.
> >
> > So I began to try and find what may have caused this problem by 
> > comparing the two sources...
> >
> > I checked the code for all references to 'oom_adj' and 'oom_adjust' in 
> > both code sets, but found no obvious differences:
> > grep -R -e oom_adjust -e oom_adj . | sort | grep -R -e oom_adjust -e 
> > oom_adj
> >
> > Then I checked for references to "-17" in all .c and .h files, and 
> > found a couple of matches, but only one obvious one:
> > grep -R "\-17" . | grep -e ".c:" -e ".h:" -e "\-17" | wc -l
> > ./include/linux/oom.h:#define OOM_DISABLE (-17)
> >
> > But again, a search for OOM_DISABLE came up with nothing obvious...
> >
> > In a last ditch attempt, I did a search for all references to 'oom' 
> > (case-insensitive) in both code bases, then compared the two:
> >  root@annabelle [~/lol/linux-2.6.32.28] > grep -i -R "oom" . | sort -n 
> > > /tmp/annabelle.oom_adj
> >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > grep -i -R 
> > "oom" . | sort -n > /tmp/vicky.oom_adj
> >
> > and this brought back (yet again) nothing obvious..
> >
> >
> >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > md5sum 
> > ./include/linux/oom.h
> > 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
> >
> >  root@annabelle [~/lol/linux-2.6.32.28] > md5sum ./include/linux/oom.h
> > 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
> >
> >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > md5sum 
> > ./mm/oom_kill.c
> > 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
> >
> >  root@annabelle [~/lol/linux-2.6.32.28] > md5sum ./mm/oom_kill.c
> > 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
> >
> >
> >
> > Could anyone please shed some light as to why the default oom_adj is 
> > set to -17 now (and where it is actually set)? From what I can tell, 
> > the fix for this issue will either be:
> >
> >   1. Allow OOM killer to override the decision of ignoring oom_adj ==
> >      -17 if an unrecoverable loop is encountered.
> >   2. Change the default back to 0.
> >
> > Again, my apologies if this bug report is slightly unorthodox, or 
> > doesn't follow usual procedure etc. I can assure you I have tried my 
> > absolute best to give all the necessary information though.
> >
> > Cal
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
