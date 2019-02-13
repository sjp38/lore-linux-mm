Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24689C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:49:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C88D92075D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:49:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="rF8uBA9a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C88D92075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 644CF8E0002; Wed, 13 Feb 2019 08:49:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F5508E0001; Wed, 13 Feb 2019 08:49:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BD488E0002; Wed, 13 Feb 2019 08:49:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA6D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:49:06 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f125so1692039pgc.20
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:49:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=K4Ix0st5h7mGiozd1GPE9akHFG04DKktEj6nww1TJFA=;
        b=g9byChKn5Zyr3jktoMQwp5Ba9DJD0m4xiQGuZBm2vP0cYc86i4cY2bt3zY1xDA4o3L
         JPTuSiJPzX3q6INWwCxJ+XG5bG6Uz6B37EkGr+lIxANHVRUj626V4Uh7AKrEGZA/2uSN
         YLD1PzMCyCmf6npJKSzmhpGfHt6dDtKIALcX/vhQUzPgeAhZ4+rasdae4jkSEH+O3cIb
         7qfaAWuCot7RErJ06w2BTpFpYgmp4Zd3eUUjL4xrq27Cfpavi6WKjZsMqN/XUL0Fk7dk
         lLGKqgowFzRSbytR+2ujpQ570kDj/HzKN/Vr5JXUSGB35v+H0byqwLeb5/5z0/ZgGTav
         aO/g==
X-Gm-Message-State: AHQUAuaTpmNTlkt3sw2VzTSpaquUwEgODttHFWcDOr9AiUcDEo+Lu5J3
	LZqGV+5MwX1uwEwyXWYM+pgLxnT5AgpTnvKl669P4GgqfaBEAfaYzPQQYH+stAoMIU/XN6NmmJe
	yv+Z5VOUsAImSLc/SUl3oxTn2OrRJq9W0x2tqNrg+YhxrrIqqaRg2XxaFo679GGdoo8tdzXedNo
	p99DBS2EE0ooQAz9i7z91idj+LsD6SyOUg7V40K1WkhTQ1PMlwUZRa6FwLQh8Z3pFlFHtq/gwOI
	iWoIhC/w8YkPA3h7mZKJp79QqwNayfGC31DHuR3shePe0w6qtzUv9so88nGO8T0b4J2x1YFEf1K
	yWwdFFte4p+2HwCTxxChLEbEL0skRAvx73yXaAph6QELhrPbHRGIzFPNg58r25DWaIN0+t6qAle
	T
X-Received: by 2002:a63:5d5f:: with SMTP id o31mr573038pgm.414.1550065745559;
        Wed, 13 Feb 2019 05:49:05 -0800 (PST)
X-Received: by 2002:a63:5d5f:: with SMTP id o31mr572976pgm.414.1550065744700;
        Wed, 13 Feb 2019 05:49:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550065744; cv=none;
        d=google.com; s=arc-20160816;
        b=PSdfBPVZnzNs+Y1GfyRkA2JQkHvIUnMu77cqb5nUYTObctPigedjn50MeUsMJPpFXE
         OXYiwC6s+rBsL5FQ0qHosUWS6G7phBCLxQi+tg98EDKFWxaT956X8pJ35gTLZ97ACudi
         FZ76QuAj7M/rHHOSrDQM/l4EZNo1sZkA66Ig7Ri4t+aW5gbfprFUoAd2clhvFxmWYNuK
         CtzRgMpaIjuFnLcpCL1fF3TAQJjEVhxZ8Jmsm4CmoapSKyUaF40reASB6pz7GcojyFF8
         Z84cT27qJ/9kSUNHIMtGqRpd0MqJsEekf60aprp+R3Wfn0fooM12BDYUAlBdz7SB7zyg
         yOIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=K4Ix0st5h7mGiozd1GPE9akHFG04DKktEj6nww1TJFA=;
        b=E1Nv5Ev5B4DZWzXZsjzlEmZfH8SZrq3QThqz6oQK3B5eAsUzUNVNEYmZBJ//QIEe/Z
         byyrc9jsy17oCCxPF/Of1O4x4r5PfLz48fn2pW0RT74YeGqYC1Q3Q3GcTF10MnfERkNX
         3ruwKt1bHjt2rhEisS5PEeldSIyL9fjGV2nZm8mAvap0EvpeCKJwtd4M92jq+/ELxb7U
         r33V7hQ60KWOE64N+naeeCxqFzft+JBYG+amFeN6BzHwXNrLIT1bgvyULYFRbf5lDXsz
         r5Pjhhi0mtaQF3JFn1d/3wVoV9CdkaTTm62I+/lbJrOgTnpl9GA6q0IBUGOArc6CtBfL
         d4gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=rF8uBA9a;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 24sor23183290pgq.13.2019.02.13.05.49.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:49:04 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=rF8uBA9a;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=K4Ix0st5h7mGiozd1GPE9akHFG04DKktEj6nww1TJFA=;
        b=rF8uBA9a4sCHBR2JlOHVWUlyIWFf+Bs+R2rGV/VHUNEmijV6eF3pPxV7+ymnGw8I9d
         hWXZhMk/liTccHVhHr3VCvopF3VR5MLkh8RVMyOAEBqfD2jCvQAzW3Q0WhKrgsQ6ufBu
         LjVywHneGzH35DMgGbt5UCffgPIKKFsmrRqDdKxH/WMwMGGDVL7AgzeB1h/kmxGo04fu
         PttOuiABWLIJBcSeOGTId0YqGX5qOD0DEgkJNfty0C8ZKQ0bfVNUByfFRO2T1RMHa+eD
         V/rHnEOe/CEM/qr25w+fGpaal3iTRLh2lOwOhRPTOgKLXFkWJqtlT5u3mDyPs3kh7EOx
         xCLg==
X-Google-Smtp-Source: AHgI3IZWpI9dwHhwZ4kcUXFXEiE7NTvTbTAdGqZWXyXpDvFIC7NF4DL2dXD52D5iKMiucnGeKJL6pw==
X-Received: by 2002:a65:40c5:: with SMTP id u5mr591625pgp.46.1550065743599;
        Wed, 13 Feb 2019 05:49:03 -0800 (PST)
Received: from kshutemo-mobl1.localdomain (fmdmzpr03-ext.fm.intel.com. [192.55.54.38])
        by smtp.gmail.com with ESMTPSA id z4sm12394367pgu.10.2019.02.13.05.49.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:49:02 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 70A863002B2; Wed, 13 Feb 2019 16:48:59 +0300 (+03)
Date: Wed, 13 Feb 2019 16:48:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: lsf-pc@lists.linux-foundation.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [LSF/MM TOPIC] Non standard size THP
Message-ID: <20190213134859.54tnrkzauj2mftn4@kshutemo-mobl1>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
 <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
 <282f6d89-bcc2-2622-1205-7c43ba85c37e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <282f6d89-bcc2-2622-1205-7c43ba85c37e@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 06:20:03PM +0530, Anshuman Khandual wrote:
> 
> 
> On 02/12/2019 02:03 PM, Kirill A. Shutemov wrote:
> > On Fri, Feb 08, 2019 at 07:43:57AM +0530, Anshuman Khandual wrote:
> >> Hello,
> >>
> >> THP is currently supported for
> >>
> >> - PMD level pages (anon and file)
> >> - PUD level pages (file - DAX file system)
> >>
> >> THP is a single entry mapping at standard page table levels (either PMD or PUD)
> >>
> >> But architectures like ARM64 supports non-standard page table level huge pages
> >> with contiguous bits.
> >>
> >> - These are created as multiple entries at either PTE or PMD level
> >> - These multiple entries carry pages which are physically contiguous
> >> - A special PTE bit (PTE_CONT) is set indicating single entry to be contiguous
> >>
> >> These multiple contiguous entries create a huge page size which is different
> >> than standard PMD/PUD level but they provide benefits of huge memory like
> >> less number of faults, bigger TLB coverage, less TLB miss etc.
> >>
> >> Currently they are used as HugeTLB pages because
> >>
> >> 	- HugeTLB page sizes is carried in the VMA
> >> 	- Page table walker can operate on multiple PTE or PMD entries given its size in VMA
> >> 	- Irrespective of HugeTLB page size its operated with set_huge_pte_at() at any level
> >> 	- set_huge_pte_at() is arch specific which knows how to encode multiple consecutive entries
> >> 	
> >> But not as THP huge pages because
> >>
> >> 	- THP size is not encoded any where like VMA
> >> 	- Page table walker expects it to be either at PUD (HPAGE_PUD_SIZE) or at PMD (HPAGE_PMD_SIZE)
> >> 	- Page table operates directly with set_pmd_at() or set_pud_at()
> >> 	- Direct faulted or promoted huge pages is verified with [pmd|pud]_trans_huge()
> >>
> >> How non-standard huge pages can be supported for THP
> >>
> >> 	- THP starts recognizing non standard huge page (exported by arch) like HPAGE_CONT_(PMD|PTE)_SIZE
> >> 	- THP starts operating for either on HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE or HPAGE_CONT_PTE_SIZE
> >> 	- set_pmd_at() only recognizes HPAGE_PMD_SIZE hence replace set_pmd_at() with set_huge_pmd_at()
> >> 	- set_huge_pmd_at() could differentiate between HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE
> >> 	- In case for HPAGE_CONT_PTE_SIZE extend page table walker till PTE level
> >> 	- Use set_huge_pte_at() which can operate on multiple contiguous PTE bits
> > 
> > You only listed trivial things. All tricky stuff is what make THP
> > transparent.
> 
> Agreed. I was trying to draw an analogy from HugeTLB with respect to page
> table creation and it's walking. Huge page collapse and split on such non
> standard huge pages will involve taking care of much details.
> 
> > 
> > To consider it seriously we need to understand what it means for
> > split_huge_p?d()/split_huge_page()? How khugepaged will deal with this?
> 
> Absolutely. Can these operate on non standard probably multi entry based
> huge pages ? How to handle atomicity etc.

We need to handle split for them to provide transparency.

> > In particular, I'm worry to expose (to user or CPU) page table state in
> > the middle of conversion (huge->small or small->huge). Handling this on
> > page table level provides a level atomicity that you will not have.
> 
> I understand it might require a software based lock instead of standard HW
> atomicity constructs which will make it slow but is that even possible ?

I'm not yet sure if it is possible. I don't yet wrap my head around the
idea yet.

> > Honestly, I'm very skeptical about the idea. It took a lot of time to
> > stabilize THP for singe page size, equal to PMD page table, but this looks
> > like a new can of worms. :P
> 
> I understand your concern here but HW providing some more TLB sizes beyond
> standard page table level (PMD/PUD/PGD) based huge pages can help achieve
> performance improvement when the buddy is already fragmented enough not to
> provide higher order pages. PUD THP file mapping is already supported for
> DAX and PUD THP anon mapping might be supported in near future (it is not
> much challenging other than allocating HPAGE_PUD_SIZE huge page at runtime
> will be much difficult).

That's a bold claim. I would like to look at code. :)

Supporting more than one THP page size at the same time brings a lot more
questions, besides allocation path (although I'm sure compaction will be
happy about this).

For instance, what page size you'll allocate for a given fault
address?

How do you deal with pre-allocated page tables? Deposit 513 page tables
for a given PUD THP page might be fun. :P

> Around PMD sizes like HPAGE_CONT_PMD_SIZE or
> HPAGE_CONT_PTE_SIZE really have better chances as future non-PMD level anon
> mapping than a PUD size anon mapping support in THP.
> 
> > 
> > It *might* be possible to support it for DAX, but beyond that...
> >
> 
> Did not get that. Why would you think that this is possible or appropriate
> only for DAX file mapping but not for anon mapping ?

DAX THP is inherently simpler: no struct pages -- less state to track and
no need in split_huge_page(), split_huge_p?d() can be handled by dropping
entities in question and re-faulting them as smaller entires. No problem
with compation...

-- 
 Kirill A. Shutemov

