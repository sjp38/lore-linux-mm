Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E15A7C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 03:07:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D54F218D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 03:07:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D54F218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F25128E0002; Sun, 17 Feb 2019 22:07:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAAD38E0001; Sun, 17 Feb 2019 22:07:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4B658E0002; Sun, 17 Feb 2019 22:07:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75BC18E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 22:07:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a9so992908edy.13
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 19:07:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=+7eq+OdatwWoZsyHXdO0ApkhZt0NfJQcOvtqqO9+6/g=;
        b=HeNwsc6b3xok52k5NFvWY2tpCesQReCrkwPJWiAHg/snNlFIpyu9hdMS1ZP1RaieT+
         aSaMq0zSjrmTLu3DD9raWMkSOKX2xgqs5pUTjcvCEefJ0d38YwbwXlTqIDLjhnc20CC1
         gC1bzQeZo1Rr3PKYpoxWLnfjJmczPtMQNyEJEJslEZGSlosQT8NahaWm4kdfAGQ3Ctfv
         vHWoP6plsGK3s8I5f5nYAimKUzZTPKr4sd+rnaDPiCW/QUXhm+dRwCK5BbjNuhHrSXj2
         +doMnbLRP/CtEjdxDR4MSgsmCD4iCGbZ2j9rn9slR57HGci0Wg3i78aPfxfswE1SX5pA
         beDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZq+KmN7CT8H9jigJA7pGP+qGPe7+7/6tvC3LAKidEVof2zZv9z
	Uf93F1ntYoSSIQLRGmr51vM4h6jjcD9VLpEZ2zSyYZNFCHWp2D3R7IFE4yhqEAgXNmPhHsuvnAn
	52qhcfbK13kas3TBRTXohJZi05U+Rt2Wu6r0GrpmwM/mDyhLlx2E9A9e8DusTlBVGbg==
X-Received: by 2002:a50:9938:: with SMTP id k53mr12331134edb.134.1550459235912;
        Sun, 17 Feb 2019 19:07:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYEjdx/mJST6CCwq1vE0uFa3fWxANI1VMAHOveCYmOaqIbUnZkP4GFn6+vDHsMDgSmHq/BG
X-Received: by 2002:a50:9938:: with SMTP id k53mr12331088edb.134.1550459234818;
        Sun, 17 Feb 2019 19:07:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550459234; cv=none;
        d=google.com; s=arc-20160816;
        b=FxYKoa1YYMNkxxm5JezNc8Y679A+SORgL3ifcGLjBzMSswD2t5mdGr50v+CDFnTCWo
         Mzu/7rGY4c7w+WUhamrEf1ccV+vL/pZpFAXRmKMr4E6h5HJklk1IdhQfF+P72wSRiFbz
         D0PQaRrCzhBYSc9XsxSEZ9DvuJtGjJ4LmtMpb1CQ3xSZQZRRbl1LY23cOXaPuu8Sut0p
         9cXPazk+NlKk0lciaraHBcg8Djs0e/WXsOE5S4GunolgsrVUSfdG50qA7t9gfUAZw147
         XTOPoEXj9VAJqOjmwSOc4d48mO7k/GfaQZhmPOJyN7LCAKIiqq8mQZI1voYWHMfTWHGG
         7tjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=+7eq+OdatwWoZsyHXdO0ApkhZt0NfJQcOvtqqO9+6/g=;
        b=uKCIDWf05fKsQywAP8OgfO80YXfVEuOZ50fUIDOQpVvmnD2RGavktB0YOHEbJEQo6w
         tB6BFwp9rPg/mQFXF0QjyxYsWf38cO4GL1ZBp6zYmpU2pTrIt6kZozbI+AmhLVbLLqKx
         h2B4Pf65TxcsFGz6PvL/sxW2q9TisJREazE7E7fhg6P4zSR4T9lg6iOiKkSw0IFAi6+o
         K6gMf6PS6B+AqbK0Jo1QJ6MdJ4f301jOdsU7W+QtVM/vRC0Bi4/SFe+qmoDIMMCAthsC
         ucEow5ZPHlpZLqEddScoZ3q4DlzwvQiwdYZujLgVqQETZphWehxoVrCb/by4Z0atvJNd
         ARxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m41si584138edc.360.2019.02.17.19.07.14
        for <linux-mm@kvack.org>;
        Sun, 17 Feb 2019 19:07:14 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 382F880D;
	Sun, 17 Feb 2019 19:07:13 -0800 (PST)
Received: from [10.162.40.135] (p8cg001049571a15.blr.arm.com [10.162.40.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6031D3F575;
	Sun, 17 Feb 2019 19:07:09 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Michal Hocko <mhocko@suse.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com,
 dave.hansen@intel.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
 <20190214083844.GZ4525@dhcp22.suse.cz>
 <20190214101936.GD9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190214122816.GD4525@dhcp22.suse.cz>
 <d2646840-f2f0-3618-889a-54cfef6cb455@arm.com>
 <20190215092746.GU4525@dhcp22.suse.cz>
Message-ID: <bd382e05-487e-06c8-9239-a2303f48b578@arm.com>
Date: Mon, 18 Feb 2019 08:37:11 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190215092746.GU4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 02/15/2019 02:57 PM, Michal Hocko wrote:
> On Fri 15-02-19 14:15:58, Anshuman Khandual wrote:
>> On 02/14/2019 05:58 PM, Michal Hocko wrote:
>>> It is hard to assume any further access for migrated pages here. Then we
>>> have an explicit move_pages syscall and I would expect this to be
>>> somewhere in the middle. One would expect that the caller knows why the
>>> memory is migrated and it will be used but again, we cannot really
>>> assume anything.
>>
>> What if the caller knows that it wont be used ever again or in near future
>> and hence trying to migrate to a different node which has less expensive and
>> slower memory. Kernel should not assume either way on it but can decide to
>> be conservative in spending time in preparing for future exec faults.
>>
>> But being conservative during migration risks additional exec faults which
>> would have been avoided if exec permission should have stayed on followed
>> by an I-cache invalidation. Deferral of the I-cache invalidation requires
>> removing the exec permission completely (unless there is some magic which
>> I am not aware about) i.e unmapping page for exec permission and risking
>> an exec fault next time around.
>>
>> This problem gets particularly amplified for mixed permission (WRITE | EXEC)
>> user space mappings where things like NUMA migration, compaction etc probably
>> gets triggered by write faults and additional exec permission there never
>> really gets used.
> 
> Please quantify that and provide us with some _data_> 
>>> This would suggest that this depends on the migration reason quite a
>>> lot. So I would really like to see a more comprehensive analysis of
>>> different workloads to see whether this is really worth it.
>>
>> Sure. Could you please give some more details on how to go about this and
>> what specifically you are looking for ?
> 
> You are proposing an optimization without actually providing any
> justification. The overhead is not removed it is just shifted from one
> path to another. So you should have some pretty convincing arguments
> to back that shift as a general win. You can go an test on wider range
> of workloads and isolate the worst/best case behavior. I fully realize
> that this is tedious. Another option would be to define conditions when
> the optimization is going to be a huge win and have some convincing

Yeah conditional approach might narrow down the field and provide better
probability for a general win. The system call (move_pages/mbind) based
migrations from the user space are better placed for an win because the
user might just want to put those pages aside for rare exec accesses in
the future and the worst case cost for those deferral is not too high as
well. A hint regarding probable rare exec access in the future for the
kernel would have been better but I am afraid it would then require a new
user interface. But I think lazy exec decision can be taken right away
for MR_SYSCALL triggered migrations for VMAs with mixed permission
([VM_READ]|VM_WRITE|VM_EXEC) knowing the fact that in worst case the
cost is just getting migrated.

MR_NUMA_MISPLACED triggered migrations requires explicit tracking of fault
type (exec/write/[read]) per VMA along with it's applicable permission to
determine if exec permission deferral would be helpful or not. These stats
can also be used for all other kernel or user initiated migrations like
MR_COMPACTION, MR_MEMORY_FAILURE, MR_MEMORY_HOTPLUG and MR_CONTIG_RANGE.

Would it be worth adding explicit fault type tracking per VMA ? Can it be
used for some other purpose as well.

> arguments that many/most workloads are falling into that category while
> pathological ones are not suffering much.
> 
> This is no different from any other optimizations/heuristics we have.

Sure. Will think about this further.

> 
> Btw. have you considered to have this optimization conditional based on
> the migration reason or vma flags?

Started considering it after our discussions here. It makes sense to look
into the migration reason and the VMA flags right away but as I mentioned
earlier VMA fault type stats can really help on this as well.

