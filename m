Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 497306B0006
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 21:32:11 -0400 (EDT)
Received: by mail-ia0-f171.google.com with SMTP id z13so4224099iaz.2
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 18:32:10 -0700 (PDT)
Message-ID: <5160CC94.6040909@gmail.com>
Date: Sun, 07 Apr 2013 09:32:04 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: fixup changers of per cpu pageset's ->high and
 ->batch
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Cody,
On 04/06/2013 04:33 AM, Cody P Schafer wrote:
> In one case while modifying the ->high and ->batch fields of per cpu pagesets
> we're unneededly using stop_machine() (patches 1 & 2), and in another we don't have any
> syncronization at all (patch 3).

Do you mean stop_machine() is used for syncronization between each 
online cpu?

>
> This patchset fixes both of them.
>
> Note that it results in a change to the behavior of zone_pcp_update(), which is
> used by memory_hotplug. I _think_ that I've diserned (and preserved) the
> essential behavior (changing ->high and ->batch), and only eliminated unneeded
> actions (draining the per cpu pages), but this may not be the case.
>
> --
>   mm/page_alloc.c | 63 +++++++++++++++++++++++++++------------------------------
>   1 file changed, 30 insertions(+), 33 deletions(-)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
