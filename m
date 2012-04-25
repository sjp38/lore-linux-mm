Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2222A6B004A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:42:32 -0400 (EDT)
Message-ID: <4F980D32.8020309@redhat.com>
Date: Wed, 25 Apr 2012 10:41:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Over-eager swapping
References: <20120423092730.GB20543@alpha.arachsys.com>
In-Reply-To: <20120423092730.GB20543@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Chris Webb <chris@arachsys.com>

On 04/23/2012 05:27 AM, Richard Davies wrote:

> The rrd graphs at http://imgur.com/a/Fklxr show a typical incident.
>
> We estimate memory used from /proc/meminfo as:
>
>    = MemTotal - MemFree - Buffers + SwapTotal - SwapFree
>
> The first rrd shows memory used increasing as a VM starts, but not getting
> near the 64GB of physical RAM.
>
> The second rrd shows the heavy swapping this VM start caused.
>
> The third rrd shows a multi-gigabyte jump in swap used = SwapTotal - SwapFree
>
> The fourth rrd shows the large load spike (from 1 to 15) caused by this swap
> storm.

These are exactly the kind of swap storms that led me
make the VM tweaks that got merged into 3.4-rc :)

See these commits:

fe2c2a106663130a5ab45cb0e3414b52df2fff0c
7be62de99adcab4449d416977b4274985c5fe023
aff622495c9a0b56148192e53bdec539f5e147f2
1480de0340a8d5f094b74d7c4b902456c9a06903
496b919b3bdd957d4b1727df79bfa3751bced1c1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
