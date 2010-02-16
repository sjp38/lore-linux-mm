Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BA06D6B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 12:12:47 -0500 (EST)
Message-ID: <4B7AD207.20604@redhat.com>
Date: Tue, 16 Feb 2010 12:12:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
References: <4B71927D.6030607@nortel.com>	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>	 <4B72E74C.9040001@nortel.com>	 <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>	 <4B74524D.8080804@nortel.com> <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com> <4B7504D2.1040903@nortel.com> <4B796D31.7030006@nortel.com> <4B797D93.5090307@redhat.com> <4B7ACD4A.10101@nortel.com>
In-Reply-To: <4B7ACD4A.10101@nortel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 02/16/2010 11:52 AM, Chris Friesen wrote:
> On 02/15/2010 11:00 AM, Rik van Riel wrote:

>> Removal from the LRU is done from the page freeing code, on
>> the final free of the page.

> There are a bunch of inline functions involved, but I think the chain
> from page_remove_rmap() back up to unmap_vmas() looks like this:
>
> page_remove_rmap
> zap_pte_range
> zap_pmd_range
> zap_pud_range
> unmap_page_range
> unmap_vmas
>
> So in this scenario, where do the pages actually get removed from the
> LRU list (assuming that they're not in use by anyone else)?

__page_cache_release

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
