Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3D46B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 04:17:28 -0400 (EDT)
Message-ID: <4C40158C.4050402@cs.helsinki.fi>
Date: Fri, 16 Jul 2010 11:17:16 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slob_free:free objects to their own list
References: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>	<AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>	<1279058027.936.236.camel@calx>	<AANLkTil-sv82zjR7yJr_3nZ0QBO_8Jwj_FO0iFubwe2s@mail.gmail.com> <AANLkTikbGTlAPAj6lbuR5nIWyBAqnfBpy3IE_LywrPID@mail.gmail.com>
In-Reply-To: <AANLkTikbGTlAPAj6lbuR5nIWyBAqnfBpy3IE_LywrPID@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Matt Mackall <mpm@selenic.com>, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Bob Liu wrote:
> This is  /proc/meminfo result in my test machine:
> without this patch:
> ===
> MemTotal:        1030720 kB
> MemFree:          750012 kB
> Buffers:           15496 kB
> Cached:           160396 kB
> SwapCached:            0 kB
> Active:           105024 kB
> Inactive:         145604 kB
> Active(anon):      74816 kB
> Inactive(anon):     2180 kB
> Active(file):      30208 kB
> Inactive(file):   143424 kB
> Unevictable:          16 kB
> ....
> 
> with this patch:
> ===
> MemTotal:        1030720 kB
> MemFree:          751908 kB
> Buffers:           15492 kB
> Cached:           160280 kB
> SwapCached:            0 kB
> Active:           102720 kB
> Inactive:         146140 kB
> Active(anon):      73168 kB
> Inactive(anon):     2180 kB
> Active(file):      29552 kB
> Inactive(file):   143960 kB
> Unevictable:          16 kB
> ...
> 
> The result show only very small improverment!
> And when i tested it on a embeded system with 64MB, I found this path
> is never called while kernel booting.

That's 1 MB improvement which is by no means small! I applied the patch. 
  Thanks Bob!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
