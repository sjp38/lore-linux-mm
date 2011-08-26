Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB486B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:18:05 -0400 (EDT)
Message-ID: <4E573A99.4060309@profihost.ag>
Date: Fri, 26 Aug 2011 08:18:01 +0200
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
MIME-Version: 1.0
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
References: <4E5494D4.1050605@profihost.ag> <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com> <4E54BDCF.9020504@profihost.ag> <20110824093336.GB5214@localhost> <4E560F2A.1030801@profihost.ag> <20110826021648.GA19529@localhost> <4E570AEB.1040703@profihost.ag> <20110826030313.GA24058@localhost> <D299D0AE-2F3C-42E2-9723-A3D7C0108C40@profihost.ag> <20110826032601.GA26282@localhost> <CAC8teKXqZktBK7+GbLgHn-2k+zjjf8uieRM_q_V7JK7ePAk9Lg@mail.gmail.com>
In-Reply-To: <CAC8teKXqZktBK7+GbLgHn-2k+zjjf8uieRM_q_V7JK7ePAk9Lg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

Yanhai,

> Stefan, is your zone_reclaim_mode enabled? try 'cat
> /proc/sys/vm/zone_reclaim_mode',
> and echo 0 to it to disable.

you're abssolutely corect zone_reclaim_mode is on - but why?
There must be some linux software which switches it on.

~# grep 'zone_reclaim_mode' /etc/sysctl.* -r -i
~#

also
~# grep 'zone_reclaim_mode' /etc/sysctl.* -r -i
~#

tells us nothing.

I've then read this:

"zone_reclaim_mode is set during bootup to 1 if it is determined that 
pages from remote zones will cause a measurable performance reduction. 
The page allocator will then reclaim easily reusable pages (those page 
cache pages that are currently not used) before allocating off node pages."

Why does the kernel do that here in our case on these machines.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
