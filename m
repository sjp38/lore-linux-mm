Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1146B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:19:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e49-v6so14806945edd.20
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:19:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f24-v6sor7656502ejb.9.2018.10.18.07.19.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 07:19:27 -0700 (PDT)
Date: Thu, 18 Oct 2018 14:19:26 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018141926.zjiebfjcodthvagg@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
 <20181018133917.GO5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018133917.GO5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 02:39:17PM +0100, Mel Gorman wrote:
>On Thu, Oct 18, 2018 at 09:04:29PM +0800, Wei Yang wrote:
>> This is not necessary to save the pfn to page->private.
>> 
>> The pfn could be retrieved by page_to_pfn() directly.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>page_to_pfn is not free which is why it's cached.
>

Hi, Mel

Thanks for your response.

Not free means the access to mem_section?

I have thought about the cache thing, so we assume the list is not that
long, and the cache could hold those page->private for the whole loop?

In my understand, it the cache has limited size, if more data accessed
the cache will be overwritten.

And another thing is:

In case of CONFIG_SPARSEMEM_VMEMMAP, would this be a little different?
Becase we get pfn by a simple addition. Which I think no need to cache
it?

Well, let me take a chance to say thanks to all, Mel, Michael and
Matthew. Hope my silly question won't bother you too much. :-)

>-- 
>Mel Gorman
>SUSE Labs

-- 
Wei Yang
Help you, Help me
