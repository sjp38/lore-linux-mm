Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0946B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:43:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so55325159wmw.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:43:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si44937936wjz.7.2016.11.30.23.43.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 23:43:42 -0800 (PST)
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <20161201071507.GC18272@dhcp22.suse.cz>
 <20161201072119.GD18272@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz>
Date: Thu, 1 Dec 2016 08:43:40 +0100
MIME-Version: 1.0
In-Reply-To: <20161201072119.GD18272@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Robin H. Johnson" <robbat2@gentoo.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Joonsoo Kim <js1304@gmail.com>

On 12/01/2016 08:21 AM, Michal Hocko wrote:
> Forgot to CC Joonsoo. The email thread starts more or less here
> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz
>
> On Thu 01-12-16 08:15:07, Michal Hocko wrote:
>> On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
>> [...]
>> > alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
>>
>> Huh, do I get it right that the request was for a _single_ page? Why do
>> we need CMA for that?

Ugh, good point. I assumed that was just the PFNs that it failed to migrate 
away, but it seems that's indeed the whole requested range. Yeah sounds some 
part of the dma-cma chain could be smarter and attempt CMA only for e.g. costly 
orders.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
