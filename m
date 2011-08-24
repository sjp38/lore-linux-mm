Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6903E6B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 05:33:41 -0400 (EDT)
Date: Wed, 24 Aug 2011 17:33:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: slow performance on disk/network i/o full speed after
 drop_caches
Message-ID: <20110824093336.GB5214@localhost>
References: <4E5494D4.1050605@profihost.ag>
 <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
 <4E54BDCF.9020504@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E54BDCF.9020504@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

On Wed, Aug 24, 2011 at 05:01:03PM +0800, Stefan Priebe - Profihost AG wrote:
> 
> >> sync&&  echo 3>/proc/sys/vm/drop_caches&&  sleep 2&&  echo 0
> >>> /proc/sys/vm/drop_caches
> 
> Another way to get it working again is to stop some processes. Could be 
> mysql or apache or php fcgi doesn't matter. Just free some memory. 
> Although there are already 5GB free.

Is it a NUMA machine and _every_ node has enough free pages?

        grep . /sys/devices/system/node/node*/vmstat

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
