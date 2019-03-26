Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF31DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:03:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABB332075C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:03:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABB332075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4362B6B0005; Tue, 26 Mar 2019 08:03:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E38B6B0006; Tue, 26 Mar 2019 08:03:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286076B0007; Tue, 26 Mar 2019 08:03:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA54B6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:03:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h27so5160814eda.8
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:03:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KpU0KW/roLtI0L8bS7wqBMXf4l7meCyTmUnBEGs810M=;
        b=UW45fHADgeJ3XQwNqy5J+866AgFCMNj36ZqR0eAnsWRzvNnWAPCsDyekn2xBUV+XhG
         nk9KJrKx781R909AxYnbZMxf3SY6XBgEnlmc3GnLtErYhLr473r0HQWYeBg7vjQ6nG6S
         qCfjchdBplccxFrEpcsv+zE9DLn4V0WPGwkm5NpZhYnMTPA1WTwsyGMMuTxsNzehJ9MZ
         xTWXNfz+37xEI6wB+gv6QksX8Wo99e0880Vc48nOaAiAxFNeVtDlXdeDsW6YR4dYmf7v
         sKPNLKyNpnA7Jql9m/A9TiEKiZAbBAlY/jwPaNNvobT/Q0MzeFD47tJ9dp9PeYKRCPRN
         l3KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUwwWXI7yU9f6pFSgjc6TPJd36fIDL2ZrrtqAuyWw/NuUIK0G6x
	nVrRw54ruPrMn/w19iHubV9R/wYIU6HBGNqaYK9xED+aTXf4FASlqej4I5GKKUGEnsbO5ZKailD
	zCwhd2bRkCgCt3ZtI0SbdMdpxAkoqQUzmkB8smRQ9maNpRdk9w4mdq5uJr/bYi/Wuhw==
X-Received: by 2002:a17:906:392:: with SMTP id b18mr14173635eja.151.1553601808360;
        Tue, 26 Mar 2019 05:03:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTKIBar6ZESYJYsx7cvMl2roSeNmIhCmPMqCIcexyJ+amVZz2eSHE6ci0VCp5hxLSEN8t/
X-Received: by 2002:a17:906:392:: with SMTP id b18mr14173552eja.151.1553601807007;
        Tue, 26 Mar 2019 05:03:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553601807; cv=none;
        d=google.com; s=arc-20160816;
        b=iO8p0yUvDekhKuk9wvGcEgyMKsPZryEBn+ImFquuIPDkdF9f7WNwZLTie8GvrqE6H/
         PERjYvJEVIVZ76n4FyVnE+gqmZVl0RUfIvyKnIG5/t25jPOukRIcRnR4VgAQXwCKmXSE
         heyK5xDkOegOduw2gi5ydNQ/tjxWZsAs6kJWf6nxnnuxB/5mv5q9DirKNrWEsqZuTuEs
         mmfivF5rDosYcZTO8t32aPiuz0a0x4nWyX6yFkyyICSMQcK6DcZdMYtB9ogBRzn0DozL
         DqfL1blm9HV1DtQallnIYTa49eLJTKH/shaRha7EiwqwrWnn5YiOaWIUokwbd2y3IsYG
         Ae8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KpU0KW/roLtI0L8bS7wqBMXf4l7meCyTmUnBEGs810M=;
        b=ohivoPI99NDrMIB8WBESmYmhg0cgPZHSgwuGomdUbD2rgM/jQcNSSWwtktXKkyo2PQ
         AaGNjXcfImHoWedAbP+ay3H7PrBeMbbYQZdaCLifU3KTvcnlsBu/NB/C5vDmMd5Cdgcz
         Je0hcMJ+21yFGNDuPWT51njR3jPbrea4Mwu4wmf0Mf/9rwXEMGRWcYChfad8E3n68aIa
         ETI0a16eSNcwlPKut7Fm28X8otE//nHkV6rNMIsweX6kSW8T3POBN6xIeJJ+OwqH0XlE
         L64SxOTaTUbCMYTiN0fgTNNM1M88PYnNYMNCXCNTC7exN8PdssfYZwQHvkBRDJNZhA6w
         t8Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d8si2234750ejk.103.2019.03.26.05.03.26
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 05:03:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BE2DD1596;
	Tue, 26 Mar 2019 05:03:25 -0700 (PDT)
Received: from [10.162.41.160] (p8cg001049571a15.blr.arm.com [10.162.41.160])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7C06B3F59C;
	Tue, 26 Mar 2019 05:03:22 -0700 (PDT)
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
 osalvador@suse.de, hannes@cmpxchg.org, akpm@linux-foundation.org,
 richard.weiyang@gmail.com, rientjes@google.com, zi.yan@cs.rutgers.edu
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
 <20190321083639.GJ8696@dhcp22.suse.cz>
 <621cc94c-210d-6fd4-a2e1-b7cfce733cf3@arm.com>
 <20190322120219.GI32418@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <65a4b160-a654-8bd3-8022-491094cf6b8f@arm.com>
Date: Tue, 26 Mar 2019 17:33:19 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190322120219.GI32418@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/22/2019 05:32 PM, Michal Hocko wrote:
> On Fri 22-03-19 11:49:30, Anshuman Khandual wrote:
>>
>> On 03/21/2019 02:06 PM, Michal Hocko wrote:
>>> On Thu 21-03-19 13:38:20, Anshuman Khandual wrote:
>>>> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
>>>> entries between memory block and node. It first checks pfn validity with
>>>> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
>>>> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
>>>>
>>>> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
>>>> which scans all mapped memblock regions with memblock_is_map_memory(). This
>>>> creates a problem in memory hot remove path which has already removed given
>>>> memory range from memory block with memblock_[remove|free] before arriving
>>>> at unregister_mem_sect_under_nodes().
>>> Could you be more specific on what is the actual problem please? It
>>> would be also helpful to mention when is the memblock[remove|free]
>>> called actually.
>> The problem is in unregister_mem_sect_under_nodes() as it skips calling into both
>> instances of sysfs_remove_link() which removes node-memory block sysfs symlinks.
>> The node enumeration of the memory block still remains in sysfs even if the memory
>> block itself has been removed.
>>
>> This happens because get_nid_for_pfn() returns -1 for a given pfn even if it has
>> a valid associated struct page to fetch the node ID from.
>>
>> On arm64 (with CONFIG_HOLES_IN_ZONE)
>>
>> get_nid_for_pfn() -> pfn_valid_within() -> pfn_valid -> memblock_is_map_memory()
>>
>> At this point memblock for the range has been removed.
>>
>> __remove_memory()
>> 	memblock_free()
>> 	memblock_remove()	--------> memblock has already been removed
>> 	arch_remove_memory()
>> 		__remove_pages()
>> 			__remove_section()
>> 				unregister_memory_section()
>>  					remove_memory_section()
>> 						unregister_mem_sect_under_nodes()
>>
>> There is a dependency on memblock (after it has been removed) through pfn_valid().
> Can we reorganize or rework the code that the memblock is removed later?
> I guess this is what Oscar was suggesting.

I could get it working with the following re-order of memblock_[free|remove] and
arch_remove_memory(). I did not observe any other adverse side affect because of
this change. Does it look okay ?

--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1863,11 +1863,11 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
        /* remove memmap entry */
        firmware_map_remove(start, start + size, "System RAM");
+       arch_remove_memory(nid, start, size, NULL);
+
        memblock_free(start, size);
        memblock_remove(start, size);
 
-       arch_remove_memory(nid, start, size, NULL);
-
        try_offline_node(nid);
 
        mem_hotplug_done();

