Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 46BF86B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 15:03:01 -0400 (EDT)
Message-ID: <502BF1F2.2020406@redhat.com>
Date: Wed, 15 Aug 2012 15:01:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Strange VM stats in /proc/zoneinfo
References: <201208151105.27411.ptesarik@suse.cz>
In-Reply-To: <201208151105.27411.ptesarik@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Tesarik <ptesarik@suse.cz>
Cc: linux-mm@kvack.org

On 08/15/2012 05:05 AM, Petr Tesarik wrote:
> Hi folks,
>
> while looking at my /proc/zoneinfo, I noticed that the counters are a bit
> strange:
>
> Node 0, zone      DMA
>    pages free     3945
>          min      7
>          low      8
>          high     10
>          scanned  0
>          spanned  4080
>          present  3905
>      nr_free_pages 3945
>
> OK, you'll probably argue that the rest is hidden in PCP differentials... BUT:
>
> 1. this machine has only 2 CPUs
> 2. stat_threshold = 4
> 3. vm_stat_diff[NR_FREE_PAGES] = 0 on both CPUs
>
> Is this only me? Or do I misrepresent what these number actually tell?

Present should always be equal to or smaller
than spanned, as well as equal to or larger
than free.

Something looks odd...

I wonder if the statistic ends up going off
at bootmem free time?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
