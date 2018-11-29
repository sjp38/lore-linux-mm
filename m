Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8F06B531E
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:54:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so1203049edr.7
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 06:54:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a36si1337168edc.92.2018.11.29.06.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 06:54:12 -0800 (PST)
Subject: Re: [PATCH] mm: hide incomplete nr_indirectly_reclaimable in
 /proc/zoneinfo
References: <20181030174649.16778-1-guro@fb.com>
 <20181129125228.GN3149@kroah.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a4495506-2dcf-922a-1b77-e915214dd041@suse.cz>
Date: Thu, 29 Nov 2018 15:54:10 +0100
MIME-Version: 1.0
In-Reply-To: <20181129125228.GN3149@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, Yongqin Liu <yongqin.liu@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 11/29/18 1:52 PM, Greg KH wrote:
> On Tue, Oct 30, 2018 at 05:48:25PM +0000, Roman Gushchin wrote:
>> BTW, in 4.19+ the counter has been renamed and exported by
>> the commit b29940c1abd7 ("mm: rename and change semantics of
>> nr_indirectly_reclaimable_bytes"), so there is no such a problem
>> anymore.
>>
>> Cc: <stable@vger.kernel.org> # 4.14.x-4.18.x
>> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")

...

> I do not see this patch in Linus's tree, do you?
> 
> If not, what am I supposed to do with this?

Yeah it wasn't probably clear enough, but this is stable-only patch, as
upstream avoided the (then-unknown) problem in 4.19 as part of a far
more intrusive series. As I've said in my previous reply to this thread,
I don't think we can backport that series to stable (e.g. it introduces
a set of new kmalloc caches that will suddenly appear in /proc/slabinfo)
so I think this is a case for exception from the stable rules.

Vlastimil

> confused,
> 
> greg k-h
> 
