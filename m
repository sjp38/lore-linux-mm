Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEC26B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:52:14 -0400 (EDT)
Date: Tue, 31 May 2011 00:52:05 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1973273.317151.1306817525160.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4DE46A4B.40401@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com



----- Original Message -----
> (2011/05/31 10:33), CAI Qian wrote:
> > Hello,
> >
> > Have tested those patches rebased from KOSAKI for the latest
> > mainline.
> > It still killed random processes and recevied a panic at the end by
> > using root user. The full oom output can be found here.
> > http://people.redhat.com/qcai/oom
> 
> You ran fork-bomb as root. Therefore unprivileged process was killed
> at first.
> It's no random. It's intentional and desirable. I mean
> 
> - If you run the same progream as non-root, python will be killed at
> first.
> Because it consume a lot of memory than daemons.
> - If you run the same program as root, non root process and privilege
> explicit
> dropping processes (e.g. irqbalance) will be killed at first.
Hmm, at least there were some programs were root processes but were killed
first.
[   pid]   ppid   uid total_vm      rss     swap score_adj name
[  5720]   5353     0    24421      257        0         0 sshd
[  5353]      1     0    15998      189        0         0 sshd
[  5451]      1     0    19648      235        0         0 master
[  1626]      1     0     2287      129        0         0 dhclient
> 
> Look, your log says, highest oom score process was killed first.
> 
> Out of memory: Kill process 5462 (abrtd) points:393 total-vm:262300kB,
> anon-rss:1024kB, file-rss:0kB
> Out of memory: Kill process 5277 (hald) points:303 total-vm:25444kB,
> anon-rss:1116kB, file-rss:0kB
> Out of memory: Kill process 5720 (sshd) points:258 total-vm:97684kB,
> anon-rss:824kB, file-rss:0kB
> Out of memory: Kill process 5457 (pickup) points:236 total-vm:78672kB,
> anon-rss:768kB, file-rss:0kB
> Out of memory: Kill process 5451 (master) points:235 total-vm:78592kB,
> anon-rss:796kB, file-rss:0kB
> Out of memory: Kill process 5458 (qmgr) points:233 total-vm:78740kB,
> anon-rss:764kB, file-rss:0kB
> Out of memory: Kill process 5353 (sshd) points:189 total-vm:63992kB,
> anon-rss:620kB, file-rss:0kB
> Out of memory: Kill process 1626 (dhclient) points:129
> total-vm:9148kB, anon-rss:484kB, file-rss:0kB
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
