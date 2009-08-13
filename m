Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A6E036B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 11:47:22 -0400 (EDT)
Message-ID: <4A843565.3010104@redhat.com>
Date: Thu, 13 Aug 2009 11:46:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090806100824.GO23385@random.random> <4A7AD5DF.7090801@redhat.com> <20090807121443.5BE5.A69D9226@jp.fujitsu.com> <20090812074820.GA29631@localhost> <4A82D24D.6020402@redhat.com> <20090813010356.GA7619@localhost>
In-Reply-To: <20090813010356.GA7619@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> On Wed, Aug 12, 2009 at 10:31:41PM +0800, Rik van Riel wrote:

>> For zones it is a fixed value, which is available in
>> /proc/zoneinfo
> 
> On my 64bit desktop with 4GB memory:
> 
>         DMA     inactive_ratio:    1
>         DMA32   inactive_ratio:    4
>         Normal  inactive_ratio:    1
> 
> The biggest zone DMA32 has inactive_ratio=4. But I guess the
> referenced bit should not be ignored on this typical desktop
> configuration?

We need to ignore the referenced bit on active anon pages
on very large systems, but it could indeed be helpful to
respect the referenced bit on smaller systems.

I have no idea where the cut-off between them would be.

Maybe at inactive_ratio <= 4 ?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
