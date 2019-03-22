Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CAD7C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 06:45:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53AA621873
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 06:45:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53AA621873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E625E6B0007; Fri, 22 Mar 2019 02:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E11A66B0008; Fri, 22 Mar 2019 02:45:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D28556B000A; Fri, 22 Mar 2019 02:45:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88BC96B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 02:45:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so533549edm.4
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 23:45:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jeuBjtqVOmernr8WaJpobUUFiNCohrFaS7X9IBg4Hnk=;
        b=r3KXT2Fw0ntW/2sDY4GaV36PPcfMf7DXAjKkNgWWhbDkQlfWVJAoLuyJbFZxIBhrBV
         bPM5IhoAGH3DK9do7m3JdJXY5NrHBByrZvHfuic/wioEF/7shxcJI4OXPaGA4EC78Xja
         iyHqTFJLIMBlsBvp63kIuUPIuZzHAYMLGdSe/03/M0pWx0ayyam0WTp4iXXKonJuVzG5
         +0K92XkSJEponiCsI/J047CoFexnJe99HKXGBqsDo+LqNNlm5DThBbxOq+jS74OpYPCC
         q/tPyPHmQfhkn4YLulriZb70vxelC6LAQGdVLcPcvNTGjLLpZ2knYyqqaM4u/xR6gGcV
         IPog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUkOFlNi1sI+utd8rCmNrQ2AKM3GRof7neJHvPmAlJfeinJnhob
	oF8XrjzwfB6Rrt2TLCY1tS/mQTVkJEf9tyWGcUoxcilIAJWxKLd8tVc6qYn0d+/ghki8zzkhpBW
	UmCpDHimoDM5ZMws9VS/Nu+vzVJm/+c14bfAZhv8pSiGGELGm/x1LDxjs82ekwfOmsg==
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr5144131ede.98.1553237158121;
        Thu, 21 Mar 2019 23:45:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhbZU5HBqv93Eb+h7IMEYYSWCMFKlqUKiCe91iMBB4JxaQ4g15nHxqPdokzFlOyQbcAE0l
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr5144090ede.98.1553237157232;
        Thu, 21 Mar 2019 23:45:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553237157; cv=none;
        d=google.com; s=arc-20160816;
        b=fWk2OlDL4sf4TddtHyKd26xUxsqp3TRFpuUxkdFczlaP5wzG9eQOs7onU/58NsS51A
         ls3PzAZpESorpjmYRAoVTuXuB5U0HoJ00Wfs6fli4vTMUvmkanm6whGykBEeGCbgvnYo
         m7+aov89pwgMoS90AsaSFdE6OCVUcamveEhb0k6aYfslQevBtlo2MSwKmHR3vDXTYqF+
         hEJJivPyyBLkyV6AjKXLxMkNiNWLMbjRHE60e59kw9TJ2RAU8sFSfb5DcIZXI/XRFFiy
         +ZBla8Fu/yreT/alwCRU7wzsBytUQ0cSw3HaSo1aSS+XHgjKWpZYkMN/utEaPs3h684F
         XVrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jeuBjtqVOmernr8WaJpobUUFiNCohrFaS7X9IBg4Hnk=;
        b=Ga+WE944XAMl39rL4+0U3YreYckSyMuyEWodu/h7aUojRoKFgRGoV4Vefun6RIZUTh
         qJbBKmo4mqZs4AJOoZ7nAr5Cp/pR4aPOMvlX3kWhh7Bzlbz9YtCHGPsxJmmGiM7fyHO4
         ECDjsV/Ymtw6iAUM+CIEov1XZnq0lo4vf1We+5tb1Fi3B2CEptXtt6uOM+ksKjy40ZKs
         nSbaedGTj0vJFIEjQyYu/cDPknBhEf48oV1OPWnGyE7KGZ7q4bAm+9oFaMOKQGRKAr3r
         S3eIIqMCevIomiVlCva032uUdtjxr1Ra5qJ/rBXVVJK6Pqr83McCi9nHpxIykIvfzRVc
         xCDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p17si2941301edc.286.2019.03.21.23.45.56
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 23:45:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E6DE680D;
	Thu, 21 Mar 2019 23:45:55 -0700 (PDT)
Received: from [10.162.42.161] (p8cg001049571a15.blr.arm.com [10.162.42.161])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 146AB3F59C;
	Thu, 21 Mar 2019 23:45:52 -0700 (PDT)
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
 hannes@cmpxchg.org, mhocko@suse.com, akpm@linux-foundation.org,
 richard.weiyang@gmail.com, rientjes@google.com, zi.yan@cs.rutgers.edu
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
 <20190321103657.22ivyuyq3k7zhy5n@d104.suse.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a53cdeee-2e25-5c94-4724-d60af1754b88@arm.com>
Date: Fri, 22 Mar 2019 12:15:50 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190321103657.22ivyuyq3k7zhy5n@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/21/2019 04:07 PM, Oscar Salvador wrote:
> On Thu, Mar 21, 2019 at 01:38:20PM +0530, Anshuman Khandual wrote:
>> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
>> entries between memory block and node. It first checks pfn validity with
>> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
>> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
>>
>> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
>> which scans all mapped memblock regions with memblock_is_map_memory(). This
>> creates a problem in memory hot remove path which has already removed given
>> memory range from memory block with memblock_[remove|free] before arriving
>> at unregister_mem_sect_under_nodes().
>>
>> During runtime memory hot remove get_nid_for_pfn() needs to validate that
>> given pfn has a struct page mapping so that it can fetch required nid. This
>> can be achieved just by looking into it's section mapping information. This
>> adds a new helper pfn_section_valid() for this purpose. Its same as generic
>> pfn_valid().
>>
>> This maintains existing behaviour for deferred struct page init case.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> I did not look really close to the patch, but I was dealing with
> unregister_mem_sect_under_nodes() some time ago [1].
> 
> The thing is, I think we can just make it less complex.
> Jonathan tried it out that patch on arm64 back then, and it worked correctly
> for him, and it did for me too on x86_64.
> 
> I am not sure if I overlooked a corner case during the creation of the patch,
> that could lead to problems.

Is there any known corner cases ?

> But if not, we can get away with that, and we would not need to worry
> about get_nid_for_pfn on hot-remove path.

The approach of passing down node ID looks good and will also avoid proposed
changes here to get_nid_for_pfn() during memory hot-remove.

> 
> I plan to revisit the patch in some days, but first I wanted to sort out
> the vmemmap stuff, which I am preparing a new version of it.
> 
> [1] https://patchwork.kernel.org/patch/10700795/
> 

Sure. Please keep me copied when you repost this patch. Thank you.

