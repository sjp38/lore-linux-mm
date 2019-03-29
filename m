Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B0B6C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:30:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5B842173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:30:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5B842173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7712D6B000E; Fri, 29 Mar 2019 04:30:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7214C6B0010; Fri, 29 Mar 2019 04:30:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 637696B0266; Fri, 29 Mar 2019 04:30:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15F796B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:30:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e55so717610edd.6
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:30:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KJmrHOp5U+9dZH7AuKYLjL1jq8R1gTGpv78lGxEGaCA=;
        b=Xoa6P2ToG1HCgBPZG1JJBtGWv/cCuyVVx7RVDGMOq2EwsIIl0osCWXejEyiXX51PKB
         8feZfzuUPClJ9OqyfM48HFzG1wO9oUfHgf8G8pD8OFdfup0EK6Ml1ZOSGl1DI5JjfkvM
         JRPrnNMWLua8GndatkHt7wz+y0fTu0eQyyGQtjTR/EjYJOlIlYcglspIS2XVUkDO31nh
         6llUszuXDHrWUaGWHv4RRBOpbsWK5GGWEKUboFxoHX6epP/FIMTFsONCqPH4Gr7xOeMc
         oF5EmLxkiRXTbSm1Vvk+bI+U59GNFyWByvUvd1TsTZZmpKGANEulTxbPv8FzKsDXx/G9
         782g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUXjOZ3bnT/1apkixEBBfy8qrDtqIwBLdtEv16wxeJzo3mUA0/H
	yA46aznNCUGYjjmJawTOFdqEus2rXUNiCPWfDQs7TQSnKulF+JIeSTjbBRdXoILULVAm/LrzF19
	T6tDDOFPK9UwJaka5rsg/nnnbcphoIdv7eQqjvdeeV7t8hcgUW4qV1d18SlDjjUlvBA==
X-Received: by 2002:a50:c201:: with SMTP id n1mr19578766edf.244.1553848212616;
        Fri, 29 Mar 2019 01:30:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBRDeoNBZC97VwEPZhxPqTth8uzUNr/JwQcvPgd+umPY7JHi2RuUCUSw+NlCSqHbDYUABp
X-Received: by 2002:a50:c201:: with SMTP id n1mr19578729edf.244.1553848211807;
        Fri, 29 Mar 2019 01:30:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553848211; cv=none;
        d=google.com; s=arc-20160816;
        b=V1gs4FWaeg6yDDLAwtSwgptlqnj/42HjyotwBYAkdO0b/jF4pHOGyHJqyOXPGNgeLT
         SvzzHImMBOXMf95E8JHQSgYbgsa46zm9pfu3ruuCCdEM5srawAM9cStKNwvkorfIAtmT
         AtxvB388ZeG2X7FX9r+UAF0g4oTMjFIRsEeiBf56CIgFaZx1zI5wD1YYEv+sUce+kMKP
         x8jWBt0IGGMvyCYcRbbFgA14Nd2WrnxqaJrkbihBk14eXkAbtrj8Un338fzcGRTIsjkD
         VDEnz6Zfh3QKGbUiY2BxnvucVamrm/Ohh6U7zrq3OBQlTAtDYEs/0w33QJuVHzG77DHn
         9GeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KJmrHOp5U+9dZH7AuKYLjL1jq8R1gTGpv78lGxEGaCA=;
        b=aZ1KYFGInjf7+dw5MtvYoflCs5WI2Bot3I4LfAK15zyqAqHsxKwgJ7krzyinjjqlxH
         4b8sKmIc0+baPhvSHJHYJDAFxW793f86iM4z9BKg6SNBnjlNdSfHz5xdQlrDibZ+bAKJ
         lWTVS2iKQ9hbjbao2xVFYhsauZWKaa6nHRvkV/4fdEbN7Mn24f8ZEEq3fN/07CP6Z1/8
         fTvrRVMAejPFKrn/YziZTwr0wtE7vDF/dNQ0YXmA3q7jAbz4Eb8CU51fsZh0wJ9Roqhz
         led8Fi/lNJhmdg9v2Q6uOyRlHqFTMmanez/ikFhvilzJo68OwkG+n5W/EqpAE/NOxzcW
         QTuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id y7si560476ejc.246.2019.03.29.01.30.11
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 01:30:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id E08F6473C; Fri, 29 Mar 2019 09:30:10 +0100 (CET)
Date: Fri, 29 Mar 2019 09:30:10 +0100
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190329083006.j7j54nq6pdiffe7v@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:09:06PM +0100, David Hildenbrand wrote:
> On 28.03.19 14:43, Oscar Salvador wrote:
> > Hi,
> > 
> > since last two RFCs were almost unnoticed (thanks David for the feedback),
> > I decided to re-work some parts to make it more simple and give it a more
> > testing, and drop the RFC, to see if it gets more attention.
> > I also added David's feedback, so now all users of add_memory/__add_memory/
> > add_memory_resource can specify whether they want to use this feature or not.
> 
> Terrific, I will also definetly try to make use of that in the next
> virito-mem prototype (looks like I'll finally have time to look into it
> again).

Great, I would like to see how this works there :-).

> I guess one important thing to mention is that it is no longer possible
> to remove memory in a different granularity it was added. I slightly
> remember that ACPI code sometimes "reuses" parts of already added
> memory. We would have to validate that this can indeed not be an issue.
> 
> drivers/acpi/acpi_memhotplug.c:
> 
> result = __add_memory(node, info->start_addr, info->length);
> if (result && result != -EEXIST)
> 	continue;
> 
> What would happen when removing this dimm (->remove_memory())

Yeah, I see the point.
Well, we are safe here because the vmemmap data is being allocated in
every call to __add_memory/add_memory/add_memory_resource.

E.g:

* Being memblock granularity 128M

# object_add memory-backend-ram,id=ram0,size=256M
# device_add pc-dimm,id=dimm0,memdev=ram0,node=1

I am not sure how ACPI gets to split the DIMM in memory resources
(aka mem_device->res_list), but it does not really matter.
For each mem_device->res_list item, we will make a call to __add_memory,
which will allocate the vmemmap data for __that__ item, we do not care
about the others.

And when removing the DIMM, acpi_memory_remove_memory will make a call to
__remove_memory() for each mem_device->res_list item, and that will take
care of free up the vmemmap data.

Now, with all my tests, ACPI always considered a DIMM a single memory resource,
but maybe under different circumstances it gets to split it in different mem
resources.
But it does not really matter, as vmemmap data is being created and isolated in
every call to __add_memory.

> Also have a look at
> 
> arch/powerpc/platforms/powernv/memtrace.c
> 
> I consider it evil code. It will simply try to offline+unplug *some*
> memory it finds in *some granularity*. Not sure if this might be
> problematic-

Heh, memtrace from powerpc ^^, I saw some oddities coming from there, but
with my code though because I did not get to test that in concret.
But I am interested to see if it can trigger something, so I will be testing
that the next days.

> Would there be any "safety net" for adding/removing memory in different
> granularities?

Uhm, I do not think we need it, or at least I cannot think of a case where this
could cause trouble with the current design.
Can you think of any? 

Thanks David ;-)

-- 
Oscar Salvador
SUSE L3

