Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 873F6C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58D4E2238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:28:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58D4E2238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBB958E0057; Thu, 25 Jul 2019 05:28:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D460F6B029D; Thu, 25 Jul 2019 05:28:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE5E18E0057; Thu, 25 Jul 2019 05:28:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4096B029B
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:28:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so31754414edu.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:28:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ueNr6vcLDvGSvmnxuxLjn3dLSHYQG8S5kIyk/Uz9+64=;
        b=P4dVAl3fNl7CubswfoY9DaPuxvwGpz2jdQemHiSBkIftUmIjmosEqYqlNT7VyMb5Jj
         t9X/OmqghE36B1naR0rhj9QbA6lkgzbRGxuJOmG2FLMn2Bdn7IBGJE6BL6USTUSIEFf9
         IX8cl18HjrLSmNx4LLIcx5hcly/GGN8WWEjCY3k4AfD+P7GDMS75YwvxCUVzpu4mLAP3
         IFZLa4XvdFw5RlXsUoWu0ozkB3aMeYYCJ25LtYmGXB6BAMoq9mhRU5ao+IdQaPG20Qdz
         ODeI3MtCI/Tfs5TNg4DoSqGJzkZ2lMi7IJwFJwgreToyPg2HKpv73ZQFvQ+BB2H5bwcJ
         WsHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUAcCKu5SkklaWJgwW9Xs0ftjNiEEZLUGTQp9PYcPuNREjBZvfo
	HatsUpgdMJB1Lw/Ldr5Sf0zFXa0jn2MtcCh91LovQWw4mjMvusXSyUCHxG0IWn8Qo/e9b5iyOD/
	NCIeySPbebc5ibdFB5X4zBl1AW9l4IrzSNnhcp0XDvKZ8wJSven4oQTiNg4yfZ4sSUg==
X-Received: by 2002:a50:f5fc:: with SMTP id x57mr76208388edm.105.1564046882000;
        Thu, 25 Jul 2019 02:28:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz2LP5qCY7XkOaGZmZO6HIX6uydc2TwTcBCuiZECaFJeuYUQ/H24Zt2kgIcCL5uwM3KMMw
X-Received: by 2002:a50:f5fc:: with SMTP id x57mr76208327edm.105.1564046881075;
        Thu, 25 Jul 2019 02:28:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564046881; cv=none;
        d=google.com; s=arc-20160816;
        b=t277YS4Fc0TLHWRQvfzyCMVUi2IhTBjwRlp6sUQjZ+97Li704t9CEr6QTBKAW512ff
         E6WglodRsBaK0Keks+55fJKn5qU6L1tJGBkd7Sh5BMUMn87neu5mW3xRo7yw4Kd0RpaE
         u79ykburIyTim3Hp+Jai8MjLprTTr5oG17s8RBW9652I+CXWNw7sxlnyKdI0QSnzpC1i
         fkWxTWHO/ZQdWwqXAGAsWxwWdAxbuSG2w6iAL7BghDVnuIRelVvISLRIBAvX8wxLxg0t
         Ivt4CUJbhSZ07byXl1MRMMaaLt+FdA4HsNIHoMZDoN6VPcskye743jba3JV0ocBw0eGH
         Splw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ueNr6vcLDvGSvmnxuxLjn3dLSHYQG8S5kIyk/Uz9+64=;
        b=wLlCDk1k2bitRH1aDAYEjdwyKNLPuVDiWWWXPs/bjLBp0wJS5Sz0vbTrBqoxS02YjB
         hjccgYteZJYZvIt9RQfgWw/qP/PPemdRNnDDLEnhIHb05aHkTZOzhQlqLMh7joTbya4K
         ItM823t4nMaRzWTUB0iugLTLPqrQxzMl3J5aOxOFmOqHRbgx8R/bYlzGQ10vsln6Krql
         6AYO/MXo5N9LE2UU2r5xpcCPfrga7+N3mtUpsSzmLVOrwvhltLpwR/gM93I49FujBFpT
         8gyyCIpsrViB8eFCUMdf0ql6wyRgIwvk7+JogoIMLDtbj+UAGDmu8Dt65PgC+fF92fUD
         bWcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23si8828162eju.114.2019.07.25.02.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:28:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 902D4ADBF;
	Thu, 25 Jul 2019 09:28:00 +0000 (UTC)
Date: Thu, 25 Jul 2019 11:27:57 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	David Hildenbrand <david@redhat.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
Message-ID: <20190725092751.GA15964@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
 <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:11:52PM -0700, Dan Williams wrote:
> On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> wrote:
> >
> > This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
> > and prepares the callers that add memory to take a "flags" parameter.
> > This "flags" parameter will be evaluated later on in Patch#3
> > to init mhp_restrictions struct.
> >
> > The callers are:
> >
> > add_memory
> > __add_memory
> > add_memory_resource
> >
> > Unfortunately, we do not have a single entry point to add memory, as depending
> > on the requisites of the caller, they want to hook up in different places,
> > (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
> > in the three callers.
> >
> > The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
> > in the way they allocate vmemmap pages within the memory blocks.
> >
> > MHP_MEMMAP_MEMBLOCK:
> >         - With this flag, we will allocate vmemmap pages in each memory block.
> >           This means that if we hot-add a range that spans multiple memory blocks,
> >           we will use the beginning of each memory block for the vmemmap pages.
> >           This strategy is good for cases where the caller wants the flexiblity
> >           to hot-remove memory in a different granularity than when it was added.
> >
> >           E.g:
> >                 We allocate a range (x,y], that spans 3 memory blocks, and given
> >                 memory block size = 128MB.
> >                 [memblock#0  ]
> >                 [0 - 511 pfns      ] - vmemmaps for section#0
> >                 [512 - 32767 pfns  ] - normal memory
> >
> >                 [memblock#1 ]
> >                 [32768 - 33279 pfns] - vmemmaps for section#1
> >                 [33280 - 65535 pfns] - normal memory
> >
> >                 [memblock#2 ]
> >                 [65536 - 66047 pfns] - vmemmap for section#2
> >                 [66048 - 98304 pfns] - normal memory
> >
> > MHP_MEMMAP_DEVICE:
> >         - With this flag, we will store all vmemmap pages at the beginning of
> >           hot-added memory.
> >
> >           E.g:
> >                 We allocate a range (x,y], that spans 3 memory blocks, and given
> >                 memory block size = 128MB.
> >                 [memblock #0 ]
> >                 [0 - 1533 pfns    ] - vmemmap for section#{0-2}
> >                 [1534 - 98304 pfns] - normal memory
> >
> > When using larger memory blocks (1GB or 2GB), the principle is the same.
> >
> > Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large contigous
> > area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when removing the
> > memory.
> 
> Concept and patch looks good to me, but I don't quite like the
> proliferation of the _DEVICE naming, in theory it need not necessarily
> be ZONE_DEVICE that is the only user of that flag. I also think it
> might be useful to assign a flag for the default 'allocate from RAM'
> case, just so the code is explicit. So, how about:

Well, MHP_MEMMAP_DEVICE is not tied to ZONE_DEVICE.
MHP_MEMMAP_DEVICE was chosen to make a difference between:

 * allocate memmap pages for the whole memory-device
 * allocate memmap pages on each memoryblock that this memory-device spans

> 
> MHP_MEMMAP_PAGE_ALLOC
> MHP_MEMMAP_MEMBLOCK
> MHP_MEMMAP_RESERVED
> 
> ...for the 3 cases?
> 
> Other than that, feel free to add:
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>

-- 
Oscar Salvador
SUSE L3

