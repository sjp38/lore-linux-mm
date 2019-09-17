Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AE3BC4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:09:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 296052189D
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:09:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 296052189D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D53A6B0008; Tue, 17 Sep 2019 11:09:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95E4C6B0006; Tue, 17 Sep 2019 11:09:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8740C6B000C; Tue, 17 Sep 2019 11:09:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 6186C6B0008
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:09:02 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F0FE318DD
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:09:01 +0000 (UTC)
X-FDA: 75944745282.14.doll36_88b6eb6cd0128
X-HE-Tag: doll36_88b6eb6cd0128
X-Filterd-Recvd-Size: 5446
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:08:59 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3F63915A2;
	Tue, 17 Sep 2019 08:08:58 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 58DA63F575;
	Tue, 17 Sep 2019 08:08:55 -0700 (PDT)
Date: Tue, 17 Sep 2019 16:08:53 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	will@kernel.org, mark.rutland@arm.com, mhocko@suse.com,
	ira.weiny@intel.com, david@redhat.com, cai@lca.pw,
	logang@deltatee.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, mgorman@techsingularity.net,
	osalvador@suse.de, ard.biesheuvel@arm.com, steve.capper@arm.com,
	broonie@kernel.org, valentin.schneider@arm.com,
	Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
Subject: Re: [PATCH V7 3/3] arm64/mm: Enable memory hot remove
Message-ID: <20190917150852.GC7305@arrakis.emea.arm.com>
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
 <20190912201517.GB1068@C02TF0J2HF1T.local>
 <ce127798-3863-0f28-de04-84b177418310@arm.com>
 <20190913100955.GB55043@arrakis.emea.arm.com>
 <a1962cde-b4df-e4a0-de61-252c0d0a25b2@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a1962cde-b4df-e4a0-de61-252c0d0a25b2@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 10:06:11AM +0530, Anshuman Khandual wrote:
> On 09/13/2019 03:39 PM, Catalin Marinas wrote:
> > On Fri, Sep 13, 2019 at 11:28:01AM +0530, Anshuman Khandual wrote:
> >> The problem (race) is not because of the inability to deal with partially
> >> filled table. We can handle that correctly as explained below [1]. The
> >> problem is with inadequate kernel page table locking during vmalloc()
> >> which might be accessing intermediate kernel page table pointers which is
> >> being freed with free_empty_tables() concurrently. Hence we cannot free
> >> any page table page which can ever have entries from vmalloc() range.
> > 
> > The way you deal with the partially filled table in this patch is to
> > avoid freeing if there is a non-empty entry (!p*d_none()). This is what
> > causes the race with vmalloc. If you simply avoid freeing a pmd page,
> > for example, if the range floor/ceiling is not aligned to PUD_SIZE,
> > irrespective of whether the other entries are empty or not, you
> > shouldn't have this problem. You do free the pte page if the range is
[...]
> > We may have some pgtable pages not freed at both ends of the range
> > (maximum 6 in total) but I don't really see this an issue. They could be
> > reused if something else gets mapped in that range.
> 
> I assume that the number 6 for maximum page possibility came from
> 
> (floor edge + ceiling edge) * (PTE table + PMD table + PUD table)

Yes.

> >> Though not completely sure, whether I really understood the suggestion above
> >> with respect to the floor-ceiling mechanism as in free_pgd_range(). Are you
> >> suggesting that we should only attempt to free up those vmemmap range page
> >> table pages which *definitely* could never overlap with vmalloc by working
> >> on a modified (i.e cut down with floor-ceiling while avoiding vmalloc range
> >> at each level) vmemmap range instead ?
> > 
> > You can ignore the overlap check altogether, only free the page tables
> > with floor/ceiling set to the start/size passed to arch_remove_memory()
> > and vmemmap_free().
> 
> Wondering if it will be better to use [VMEMMAP_START - VMEMMAP_END] and
> [PAGE_OFFSET - PAGE_END] as floor/ceiling respectively with vmemmap_free()
> and arch_remove_memory(). Not only it is safe to free all page table pages
> which span over these maximum possible mapping range but also it reduces
> the risk for alignment related wastage.

That's indeed better. You pass the floor/ceiling as the enclosing range
and start/end as the actual range to unmap is. We avoid the potential
"leak" around the edges when falling within the floor/ceiling range (I
think that's close to what free_pgd_range() does).

> >> This can be one restrictive version of the function
> >> free_empty_tables() called in case there is an overlap. So we will
> >> maintain two versions for free_empty_tables(). Please correct me if
> >> any the above assumptions or understanding is wrong.
> > 
> > I'd rather have a single version of free_empty_tables(). As I said
> > above, the only downside is that a partially filled pgtable page would
> > not be freed even though the other entries are empty.
> 
> Sure. Also practically the limitation will be applicable only for vmemmap
> mapping but not for linear mappings where the chances of overlap might be
> negligible as it covers half kernel virtual address space.

If you have a common set of functions, it doesn't heart to pass the
correct floor/ceiling in both cases.

-- 
Catalin

