Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 765966B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 23:04:12 -0400 (EDT)
Message-ID: <4FB1C7CC.3000201@kernel.org>
Date: Tue, 15 May 2012 12:04:44 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: scan_unevictable_pages sysctl/node-interface
References: <9EEC7022-38C5-46B8-8825-9FA4E98F6CF6@hachre.de>
In-Reply-To: <9EEC7022-38C5-46B8-8825-9FA4E98F6CF6@hachre.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Harald Glatt <mail@hachre.de>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 05/15/2012 07:16 AM, Harald Glatt wrote:

> Hey,
> 
> I'm reshaping my raid5 to raid6 in linux 3.3.2 with mdadm 3.2.3 atm and I got this messages in dmesg:
> 
> [390496.114687] md: reshape of RAID array md0
> [390496.114692] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
> [390496.114697] md: using maximum available idle IO bandwidth (but not more than 200000 KB/sec) for reshape.
> [390496.114707] md: using 128k window, over a total of 1465138496k.
> [390751.722771] sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled for lack of a legitimate use case.  If you have one, please send an email to linux-mm@kvack.org.
> 
> Maybe its a use case I don't know :) Just thought I'd give you a heads up. So far it seems to continue without a problem though!


We have disabled because manual rescue with sysctl is not right approach to recover stranded page on unevictable list.
We don't have received any bug report about stranded pages so that it would be no problem although you remove such sysctl calling totally. 

If you see increased nr_unevictable in /proc/vmstat compared to old, then report it to us, please. 



> 
> Harald
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
