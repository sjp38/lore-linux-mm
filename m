Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B221C6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 22:54:41 -0400 (EDT)
Message-ID: <4E570AEB.1040703@profihost.ag>
Date: Fri, 26 Aug 2011 04:54:35 +0200
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
MIME-Version: 1.0
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
References: <4E5494D4.1050605@profihost.ag> <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com> <4E54BDCF.9020504@profihost.ag> <20110824093336.GB5214@localhost> <4E560F2A.1030801@profihost.ag> <20110826021648.GA19529@localhost>
In-Reply-To: <20110826021648.GA19529@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

Hi Wu,

> Ah you are running an older kernel that didn't show all the vmstat
> numbers. But still it's revealing that node 0 is used heavily and node
> 1 is almost idle. So I won't be surprised to see most free pages lie
> in node 1.
I'm running a 2.6.38 kernel.

There is at least a numastat proc file.
grep . /sys/devices/system/node/node*/numastat
/sys/devices/system/node/node0/numastat:numa_hit 5958586
/sys/devices/system/node/node0/numastat:numa_miss 0
/sys/devices/system/node/node0/numastat:numa_foreign 0
/sys/devices/system/node/node0/numastat:interleave_hit 4191
/sys/devices/system/node/node0/numastat:local_node 5885189
/sys/devices/system/node/node0/numastat:other_node 73397
/sys/devices/system/node/node1/numastat:numa_hit 488922
/sys/devices/system/node/node1/numastat:numa_miss 0
/sys/devices/system/node/node1/numastat:numa_foreign 0
/sys/devices/system/node/node1/numastat:interleave_hit 4187
/sys/devices/system/node/node1/numastat:local_node 386741
/sys/devices/system/node/node1/numastat:other_node 102181

>> modified it a little bit:
>> ~# while [ true ]; do ps -eo
>> user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd
>> | grep scp | grep -v grep; sleep 1; done
>>
>> root     12409 12409 TS       -   0  19   0 59.8  42136  1724  0.0 Ss
>> poll_schedule_timeout        scp -t /tmp/
>
> It's mostly doing poll() waits. There must be some dependency on
> something other to make progress. Would you post the full ps output
> for all tasks, and even better, run
complete ps output:
http://pastebin.com/raw.php?i=b948svzN

>          echo t>  /proc/sysrq-trigger
sadly i wa sonly able to grab the output in this crazy format:
http://pastebin.com/raw.php?i=MBXvvyH1

Hope that still helps.

Thanks Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
