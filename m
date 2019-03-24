Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11015C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 06:12:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A50E721741
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 06:12:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A50E721741
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04B2D6B0003; Sun, 24 Mar 2019 02:12:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F12C46B0006; Sun, 24 Mar 2019 02:12:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB54B6B0007; Sun, 24 Mar 2019 02:12:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 89E6B6B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 02:12:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s27so2554088eda.16
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 23:12:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BPo9kWXourZbj/SnypaDRDwu4Pu/zqTZwKvNh6zUlo4=;
        b=WgMKd+u4IlZeCPcXirYLUHus2D04yk7uOys6QygLxlUCWXsSq0cVFJdhC2xwWIRnh6
         1FvI6RC2NMFdf0NTkRdTudX0VjvN+7j2ihraMaGvdGhM3u2P/gsf7QMGt0hKv58re7t0
         L1QYiy12hKd56qHb/Qp2o3hyWxZYWbDZaB3lkqTY9dRHvw02u0YLnpAm38zF9G9jDTkj
         Sm4xLCoAnnLLgvZJN2RG+TYEwmWX6kFNC8BtpShY45s+9INBjOuFSYjgtJgoqTk8XDVl
         0Xdo7y7DtnJ3Po76JSNYxMmzZ+CmY7qcDBKDbEr0xLk2rniL+9C2NA0AI0yQiS06CtXP
         Z/8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVfXV4T2JP7GViohxXjmF46HgqozaFxyz0ZpN5XZncUrZVpIhQC
	22XgRbvH/VVKA6K/yWhgQaEF0ellgPbH1J6UEFjHB6i+5DSalbWS8jQARAlTFvYU0j2y4yY08UJ
	3CC8tCBD+H8XUw4V0m+l/IeQEqcUteIJUa5wtSd3mCZXaRvDuXcQ7r+Y4TgSLmCaHaA==
X-Received: by 2002:a50:8977:: with SMTP id f52mr11956331edf.78.1553407966952;
        Sat, 23 Mar 2019 23:12:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyon4v558EU41qsRVCfShidcmLnOrSyPm9DWVBC+mn20MbqPveQYEmcRoJFoEDosufkAZBX
X-Received: by 2002:a50:8977:: with SMTP id f52mr11956282edf.78.1553407965704;
        Sat, 23 Mar 2019 23:12:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553407965; cv=none;
        d=google.com; s=arc-20160816;
        b=lveAOZu7OMkAIHTV5ExfpBpQRUdzYfneU+bMtPrgL2NKbW4pfeSl1RLVDwZ8vKEj4Y
         6mvb+fWXNsObmoxn/I7Ndfh/s1fx0tvDXj3DYue1j4M+/jl2YoWNYFrLluGRJq+Dodzz
         qbZ/bjB4uFXnZ0zcAs+G7fsJIOI7rmT1Cm4cIUUABEkNITsrJHpvC2EE6Gti0JM2X0U4
         74zu+SCLB6WGw0/mzX9yehGV29bOFVd+7n4l9TgX78jv0u7K5NyYGz9SdcfSf0sUDfxT
         nZA7s/9eZV7dN3SDFCA8POLCrjhXWFLUXM31cEE5kNEv+0pimjcIdihglWa0qE4Hs5Ow
         OD4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BPo9kWXourZbj/SnypaDRDwu4Pu/zqTZwKvNh6zUlo4=;
        b=A547mfuKMjdmAUztsTZzPHzqJMqix5e5Mti2wsDvlJM6PxVS3/mlIRwTYRMMZjmMJ/
         Rhka+eiSjWQCiQG9Aa/c00cYm3pPjYvYX56g6jD8U/o+IfEhrphPaLpfcuz/cQcqBc2p
         9uyQb8bGWxlbtMyuzaZGwMjyV88Kj47TVtyj4W2727m0XkJkeXWPRKu1xUd/jHAZxTz/
         r+gP7/GNNZj6RpVavR6UTHklB6Zt2sD48hB3qZykWOwcmALXSg9ITXbpwOr9Ms3abAMF
         1CcgUO4oKlrDrESC2dItMGtmEiK0lmpgdjzfiBucqjiylTR3eoFPc5jXTte9+nqNRn56
         Lixw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p18si1301055ejj.234.2019.03.23.23.12.45
        for <linux-mm@kvack.org>;
        Sat, 23 Mar 2019 23:12:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DEB17EBD;
	Sat, 23 Mar 2019 23:12:43 -0700 (PDT)
Received: from [10.162.41.135] (p8cg001049571a15.blr.arm.com [10.162.41.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4F78F3F575;
	Sat, 23 Mar 2019 23:12:42 -0700 (PDT)
Subject: Re: [RFC] mm/memory_hotplug: wrong node identified if memory was
 never on-lined.
To: Jonathan Cameron <jonathan.cameron@huawei.com>, linux-mm@kvack.org
Cc: linuxarm@huawei.com, Oscar Salvador <osalvador@techadventures.net>
References: <20180912150218.00002cbc@huawei.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <45aab69f-ab0c-7f6e-c386-ed873d099699@arm.com>
Date: Sun, 24 Mar 2019 11:42:37 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20180912150218.00002cbc@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Jonathan,

On 09/12/2018 07:32 PM, Jonathan Cameron wrote:
> Hi All,
> 
> I've been accidentally (i.e. due to a script bug) testing some odd corner
> cases of memory hotplug and run into this issue.
> 
> If we hot add some memory we have carefully avoided the need to use
> get_nid_for_pfn as it isn't set until we online the memory.

get_nid_for_pfn() gets avoided during memory hot add into an existing and
initialized node.

add_memory(nid, start, size)
	add_memory_resource(nid, res, online)
		link_mem_sections(nid, start_pfn, nr_pages, false)
			register_mem_sect_under_node(mem_blk, nid, false)
				sysfs_create_link_nowarn()
> 
> Unfortunately if we never online the memory but instead just remove it again
> we don't have any such protection so in unregister_mem_sect_under_nodes
> we end up trying to call sysfs_remove_link for memory on (typically) node0
> instead of the intended node.

Are you some how calling arch_remove_memory() directly instead of going through
__remove_memory() first. Because __remove_memory() will remove the range from
memblock first making pfn_valid() fail in get_nid_for_pfn() on arm64 platform
because of the memblock search for mapped memory. Just wondering how you did
not hit this problem first. But yes if you have some how crossed this point you
will probably see page_to_nid(pfn_to_page(pfn)) return as 0 for an uninitialized
page because the page never went online first.

> 
> So the path to this problem is
> 
> add_memory(Node, addr, size);
> -> add_memory_resource(Node ...)
> ---> link_mem_sections(Node ...)
> ------> register_mem_sect_under_node(
> ----------> sysfs_create_link_nowarn(&node_devices[Node]->dev.kobj,...
> (which creates the link to say
> /sys/bus/nodes/devices/node5/memory84
> 
> Note that in code we avoid checking the nid set for the pfn in hotplug
> paths.

Right.

> 
> remove_memory(Node, addr, size);
> -> arch_remove_memory(start, size, NULL);
> ---> __remove_pages
> -----> __remove_section
> -------> unregister_memory_section
> ----------> remove_memory_section(Node,... -- Node set to 0 but not used at all.
> -------------> unregister_mem_sect_under_node() - node not passed in anyway
> ---------------->get_nid_for_pfn(pfn).  (try to get it back again)
> -------------------->sysfs_remove_link (wrong node number)
> tries to remove
> /sys/bus/nodes/devices/node0/memory84 which doesn't exist.
> 
> So not tidy, but not critical - but you get BUG_ON when you try
> to add the memory again as there is a left over link in the way.

Afterwards the system is anyway broken from memory hotplug point of view atleast.

> 
> 
> Now I'm not sure what the preferred fix for this would be.
> 1) Actually set the nid for each pfn during hot add rather than waiting for
>    online.

IIUC that will try to partially init a page only with it's nid and nothing else.
Not sure if that will be okay.

> 2) Modify the whole call chain to pass the nid through as we know it at the
>    remove_memory call for hotplug cases...


Both the top level functions has got nid. Wondering why page_to_nid() still needs
to be fetched while creating or removing sysfs links. Is there some corner cases
where nid might change while memory hot add/remove is already in progress with
hotplug lock.

__add_memory(nid, start, size)
__remove_memory(nid, start, size)

> 
> I personally favour option 2 but don't really have a deep enough understanding
> to know if this is going to cause trouble anywhere else.
> 
> I mocked up option 2 using some updated arm64 hotplug patches and it seems
> superficially fine if fairly invasive.
> 
> The whole structure is a little odd in that in the probe path the sysfs links
> are not called via architecture specific code whilst in the remove they are.

Right. I guess thats because __add_pages(called from arch_add_memory) does not
create the link where as __remove_pages(called from arch_remove_memory) removes
the sysfs link.

