Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 321D16B0034
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 15:15:22 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id l10so2721215oag.19
        for <linux-mm@kvack.org>; Fri, 16 Aug 2013 12:15:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130816190106.GD22182@sgi.com>
References: <1376545589-32129-1-git-send-email-yinghai@kernel.org>
	<20130815134348.bb119a7987af0bb64ed77b7b@linux-foundation.org>
	<20130816190106.GD22182@sgi.com>
Date: Fri, 16 Aug 2013 12:15:21 -0700
Message-ID: <CAE9FiQUYccFLzfHcjx+cgLky0UH8h99msDsNdAR7WdLpzwFQ2A@mail.gmail.com>
Subject: Re: [PATCH] memblock, numa: Binary search node id
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 16, 2013 at 12:01 PM, Russ Anderson <rja@sgi.com> wrote:
> On Thu, Aug 15, 2013 at 01:43:48PM -0700, Andrew Morton wrote:
>> On Wed, 14 Aug 2013 22:46:29 -0700 Yinghai Lu <yinghai@kernel.org> wrote:
>>
>> > Current early_pfn_to_nid() on arch that support memblock go
>> > over memblock.memory one by one, so will take too many try
>> > near the end.
>> >
>> > We can use existing memblock_search to find the node id for
>> > given pfn, that could save some time on bigger system that
>> > have many entries memblock.memory array.
>>
>> Looks nice.  I wonder how much difference it makes.
>
> Here are the timing differences for several machines.
> In each case with the patch less time was spent in __early_pfn_to_nid().
>
>
>                         3.11-rc5        with patch      difference (%)
>                         --------        ----------      --------------
> UV1: 256 nodes  9TB:     411.66          402.47         -9.19 (2.23%)
> UV2: 255 nodes 16TB:    1141.02         1138.12         -2.90 (0.25%)
> UV2:  64 nodes  2TB:     128.15          126.53         -1.62 (1.26%)
> UV2:  32 nodes  2TB:     121.87          121.07         -0.80 (0.66%)
>                         Time in seconds.
>

Thanks.

9T one have more entries in memblock.memory?

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
