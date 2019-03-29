Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D08CC10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 511EE2183F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:20:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 511EE2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA0F96B026B; Fri, 29 Mar 2019 05:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4EAF6B026C; Fri, 29 Mar 2019 05:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40FE6B026D; Fri, 29 Mar 2019 05:20:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 854326B026B
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:20:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d2so746905edo.23
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:20:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+DHyAQdH87cVQku2yPVIAe5WhLfzRw8dGpVo236sqIs=;
        b=Y8o4zpMJLM4QJ0t4rMHhMmFzh1NqvIkOIB2qj1qsu2s3kUHfFEzMjS1X3xXkK3XXx1
         U1pLYyCh+sfPF9DvgrBddt9Ozva3olos7RT8FfMSK/30FdHRl1UnRHSncY/oCpirsQh7
         YmqXWgxUcB61xSv3l5cpS0DNkCtoupO9dZK9SUrzYjyDC4oNfI7q/2D0VFm6004PXoZO
         8ltrLnGAZixlwKazC7RAisqAjFf0AMV9ZK3MB82afRiW1jv0NnFR6Zj7nprZq/1ZxYrf
         d0OKxZSXsKDiPt2wFPy4AcY7AZVMUSe5KkmPyQRPT7CYUnl9rvad2vKMSQe0ujRbqzVD
         Wy7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVxPKhmVkwH2P6NsiDW9IF05xRQHF9Bt0maTmrYPoOfEgX4UQj7
	vzeoYqhpwwKBWkEQu5jbaKnsF1GCGxf4dlHngqG/TD4/5KkEIOF36eQY3UlRuRVUGgfNO5w6nAg
	/3JUi7gOcXwwGDRmV0wpu6W/pMc3gCjTN5rXqNZPhCPr4/wpDZjy2NrKfHtZuSYKa0w==
X-Received: by 2002:a17:906:6d99:: with SMTP id h25mr10782134ejt.187.1553851227079;
        Fri, 29 Mar 2019 02:20:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzK13ZPdcnwcINGksLFL1paLP5GZTFxYa+9MtLzRlK0dj4QrN08IUyqiX0TJG+NDurvDv/N
X-Received: by 2002:a17:906:6d99:: with SMTP id h25mr10782109ejt.187.1553851226329;
        Fri, 29 Mar 2019 02:20:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553851226; cv=none;
        d=google.com; s=arc-20160816;
        b=hzP1UcJLd6QzAhmORDe9bpNlyn8hjZ6XqC4dibe1o7y0jDWpcvhHccjoycpdSsyuCR
         e3CVklGCEWzS3BdK7Tx7miUTgTOrVMt45MpUNbFKvrIwbT3/kyM7G534ufjtQ0QbLq45
         DvrGGs40i7zJyLfCZvp/5wxuW3vu3bnFWGw+HX13KWHUGpgJW5kVSfBnGZWt9Qw/Krdb
         BkbayYB/+Wylgt+ClUcHlSvo5Yi9Cgy1GFi47FN3xFevj6vQxz4s3MBO97WqZ1iuY5bO
         DrzgshfRTg/DdRopwMJWVww7Md+2sbCS3f9gKWYTUHJMbWSD0eS8g923TC6LiqW7zMam
         4FHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+DHyAQdH87cVQku2yPVIAe5WhLfzRw8dGpVo236sqIs=;
        b=D/xyPQoE3+WgcNAdCpc1EixPhpj3LCUt4pGlLUmikeMj0qLHmtspJAOGvbN8fmyg9t
         nejOzMFSoUTAV1CGFP1ZiAGBz0HDir2BES1jHhIOkXtMjDrYCHaJRCSqy95TcJG5ZDJa
         D/dWxcFBtVoh8Vurb29AqBibuUxim92Lru9MQ+2aOzCemqVFS2/wOG77QCEAvTX59gfQ
         qaBEY3tEVnwIJTiXJnHtn0S5ySbwKkoeVjrkQt7jbm25GDDmZ84RbwwnznFAqAzWSE9v
         kwX7Q2yvuVyW4J5wqtznj8bz9XQ6/UotPzXv6wC66qE7U1TEUuPnCZ0Ogft7k8Hq6qcn
         DUeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id k13si726990edr.161.2019.03.29.02.20.26
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 02:20:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 7DB014740; Fri, 29 Mar 2019 10:20:25 +0100 (CET)
Date: Fri, 29 Mar 2019 10:20:25 +0100
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190329092025.2cw3igplwzrij2sr@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <23dcfb4a-339b-dcaf-c037-331f82fdef5a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <23dcfb4a-339b-dcaf-c037-331f82fdef5a@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 09:56:37AM +0100, David Hildenbrand wrote:
> Oh okay, so actually the way I guessed it would be now.
> 
> While this makes totally sense, I'll have to look how it is currently
> handled, meaning if there is a change. I somewhat remembering that
> delayed struct pages initialization would initialize vmmap per section,
> not per memory resource.

Uhm, the memmap array for each section is built early during boot.
We actually do not care about deferred struct pages initialization there.
What we do is:

- We go through all memblock regions marked as memory
- We mark the sections within those regions present
- We initialize those sections and build the corresponding memmap array

The thing is that sparse_init_nid() allocates/reserves a buffer big enough
to allocate the memmap array for all those sections, and for each memmap
array to need to allocate, we consume it from that buffer, using contigous
memory.

Have a look at:

- sparse_memory_present_with_active_regions()
- sparse_init()
- sparse_init_nid
- sparse_buffer_init

> But as I work on 10 things differently, my mind sometimes seems to
> forget stuff in order to replace it with random nonsense. Will look into
> the details to not have to ask too many dumb questions.
> 
> > 
> > So, the taken approach is to allocate the vmemmap data corresponging to the
> > whole DIMM/memory-device/memory-resource from the beginning of its memory.
> > 
> > In the example from above, the vmemmap data for both sections is allocated from
> > the beginning of the first section:
> > 
> > memmap array takes 2MB per section, so 512 pfns.
> > If we add 2 sections:
> > 
> > [  pfn#0  ]  \
> > [  ...    ]  |  vmemmap used for memmap array
> > [pfn#1023 ]  /  
> > 
> > [pfn#1024 ]  \
> > [  ...    ]  |  used as normal memory
> > [pfn#65536]  /
> > 
> > So, out of 256M, we get 252M to use as a real memory, as 4M will be used for
> > building the memmap array.
> > 
> > Actually, it can happen that depending on how big a DIMM/memory-device is,
> > the first/s memblock is fully used for the memmap array (of course, this
> > can only be seen when adding a huge DIMM/memory-device).
> > 
> 
> Just stating here, that with your code, add_memory() and remove_memory()
> always have to be called in the same granularity. Will have to see if
> that implies a change.

Well, I only tested it in such scenario yes, but I think that ACPI code
enforces that somehow.
I will take a closer look though.

-- 
Oscar Salvador
SUSE L3

