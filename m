Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EA63C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 10:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6A3820823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 10:12:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="PCzIgLc6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6A3820823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46E718E0003; Mon,  4 Mar 2019 05:12:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7EB8E0001; Mon,  4 Mar 2019 05:12:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29A3E8E0003; Mon,  4 Mar 2019 05:12:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD47D8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 05:12:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o67so4843555pfa.20
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 02:12:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CkJ+KuNY5pToHIhpo3yQhG/5fy3Y69T409vy4zpky6A=;
        b=SiPwo2TEDOVceKszv+6BqC5htgt2v+5pkFmPBpCqHamjn26D0mvuwr4Dd2OYvBZbzz
         lcDsN4Ek6v0K4s0s7nCGTKceSVH0oTkm2cf1Blo5MnzI5ufAJ1mz1D80kQbOgmVJLcTE
         RUwGvh+el9Djr400SN9OG5cpjWbr1r2mbD0304c/D4LuAujuVNgdC15QEKXrYTDRrJWg
         LdIc7GGmq4kgR0af2oD3p01YCNAv2UGIteXxwNKO7grPpKzfShZa7DF5teMGjq5jk/p7
         iW4WfHFG3NFp3UZIOrF3U3zNk45W8jdFbjeAJ/a2XiCreWMoj8rps7TbGIE2EuPDWGv0
         Ltsw==
X-Gm-Message-State: APjAAAVC1/6ptdJDADs32sONVl9kDAP1TLhWLPLJ+FTdRyBfWxd2n5rJ
	uSWQwFg+xwjva0nJ0G89BJv5Ktu3ozVloN4yc/6RfbSLy59DjwaNYyqXylrEJ45fmp/eSyAkFzo
	f7pamizGunRAVu3WDEI3WjtBoOrzvuCykpDMcTqJ5OiW8L+i3TMtYAYXUbzLhlm0iqf+EPzpun6
	sCDPWSxyjrAUqlE74uN7SwD/rXpWlgoAlqfLYielLj9On7b7XhHVdGledy8faidM2p+dcnY+NO8
	03DTpg/R8VSRI52Y+5TW2tYgwDuoXtTMO2wXOnewaBbSR9t4gWV4951uYhHxHHpbdpT/WltgHxe
	/1OTU3Srrl/7FUdocwqwDKlViaJbx1hfMjZpU2xfywC4Qz1RQ4R0xv1ERDpsPnhjrC1tVMU+M5G
	5
X-Received: by 2002:a63:4c18:: with SMTP id z24mr17981466pga.62.1551694336466;
        Mon, 04 Mar 2019 02:12:16 -0800 (PST)
X-Received: by 2002:a63:4c18:: with SMTP id z24mr17981395pga.62.1551694335334;
        Mon, 04 Mar 2019 02:12:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551694335; cv=none;
        d=google.com; s=arc-20160816;
        b=RGa0MHiKCdc6i2eZ/Td7ttxg2woX6srZez7hVDGVOHY/iM8lXqIXFjXHiScq5gKWt9
         tFsukTxwS/oluI8H66EzBqzPUMu+dXPA8Ddqn9/l8fP3d7qx9N4zatqaFYP9YMfsKni8
         cAWRo1UXwqZ6VLupOPlOaJYmhIFkpz6h3fRjk4eR/Ne9+HHmNf2+P8YkP1Guv4yMDj6x
         tG7wD4Z4kW9EZhegcZJAxl6/ok6ySPcxh4iyfhzJRZY3Ix936Ga0J2R+Vz/54luYmJ1M
         VipW6Dli+o3j+q4Um6tfhOpKh2tXnYzBghs06K210iJxE4LsiOVwNb2HjVlp8OgdfFrp
         Rk0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CkJ+KuNY5pToHIhpo3yQhG/5fy3Y69T409vy4zpky6A=;
        b=mSytqBFWvsBhqUHfU2RiRMjlCk4svYnlvLLO0X3DjaZEmi1jDBWUFu2U3ngPhmWdVu
         QFvjyI9IIsXHR6C7Sui3Wa/sSVkx/TPpolcIQDJt8rhtBFtGttvmWSni7a/2TDn6uWJz
         KEpNvnggbY4O50fiIStc1LTNF3rBG4MoGv08EcGhqxhuPN448ODK1Ashx7jPz1ztXeyT
         E54LDOgHXR2iNkXQm0ThDcy8CBjGfiKL4UUhKEBr0fk1jj30UXN/GgDCBVBgFJ41cofN
         BdUXNzY/0SbOLaKFhPuP8GNzm4o/CCGVrzzqpTW7PWDxjLt6QgZEpqMabb5CNVokguFr
         2wqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PCzIgLc6;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor7940858plz.8.2019.03.04.02.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 02:12:15 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PCzIgLc6;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CkJ+KuNY5pToHIhpo3yQhG/5fy3Y69T409vy4zpky6A=;
        b=PCzIgLc6Qr7Faq00HLYJa3YAPFY+F7lZr8J7v3GUDplDwZ+YiAC+GzVkO2cXSwZCPq
         z78fdtDGTAB9DP1u4YN+rP9IhpQnwdjKxnR2tnVlyceIZbyESqOLIpdXAMICaMbsawE/
         jVYi+THopYmxgZRjSPwUaZujXxVyzBRCIB/AThZfRdBR9CPpFoUi952qrKROM7SWHHP1
         Yw6lVbM3eCCyyOKLU31EICVFc6olWQsKBzoKWg2mLgUqtwhDpC8L4wp36kCC4Z232t01
         vqni6Qag2WAQ8f9hRwiOXQWgfmuXSwRjShKQG7Qe7crkoDQtPmmn0wYbvvPYuFnoAFyn
         J3pw==
X-Google-Smtp-Source: APXvYqyO1Al0er+EbQQuLPUJeqKknjAc+7kTAPvQod18FwFzzv1DVrILxDBnUqL0UO7KF6F5+SuR9g==
X-Received: by 2002:a17:902:e90b:: with SMTP id cs11mr19129368plb.197.1551694334729;
        Mon, 04 Mar 2019 02:12:14 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id v8sm8749675pfm.174.2019.03.04.02.12.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 02:12:13 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 201A4300429; Mon,  4 Mar 2019 13:12:10 +0300 (+03)
Date: Mon, 4 Mar 2019 13:12:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
Message-ID: <20190304101209.klwojazhtr4s4reu@kshutemo-mobl1>
References: <20190301035550.1124-1-aarcange@redhat.com>
 <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
 <3e8b2ff0-d188-5259-b488-e31355e1e8ad@suse.cz>
 <20190301165452.GP14294@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190301165452.GP14294@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 11:54:52AM -0500, Andrea Arcangeli wrote:
> Hello Kirill and Vlastimil,
> 
> On Fri, Mar 01, 2019 at 02:04:38PM +0100, Vlastimil Babka wrote:
> > On 3/1/19 10:37 AM, Kirill A. Shutemov wrote:
> > > On Thu, Feb 28, 2019 at 10:55:48PM -0500, Andrea Arcangeli wrote:
> > >> Hello,
> > >>
> > >> This was a well known issue for more than a decade, but until a few
> > >> months ago we relied on the compiler to stick to atomic accesses and
> > >> updates while walking and updating pagetables.
> > >>
> > >> However now the 64bit native_set_pte finally uses WRITE_ONCE and
> > >> gup_pmd_range uses READ_ONCE as well.
> > >>
> > >> This convert more racy VM places to avoid depending on the expected
> > >> compiler behavior to achieve kernel runtime correctness.
> > >>
> > >> It mostly guarantees gcc to do atomic updates at 64bit granularity
> > >> (practically not needed) and it also prevents gcc to emit code that
> > >> risks getting confused if the memory unexpectedly changes under it
> > >> (unlikely to ever be needed).
> > >>
> > >> The list of vm_start/end/pgoff to update isn't complete, I covered the
> > >> most obvious places, but before wasting too much time at doing a full
> > >> audit I thought it was safer to post it and get some comment. More
> > >> updates can be posted incrementally anyway.
> > > 
> > > The intention is described well to my eyes.
> > > 
> > > Do I understand correctly, that it's attempt to get away with modifying
> > > vma's fields under down_read(mmap_sem)?
> 
> The issue is that we already get away with it, but we do it without
> READ/WRITE_ONCE. The patch should changes nothing, it should only
> reduce the dependency on the compiler to do what we expect.

Yes, it is pre-existing problem. And yes, complier may screw this up.
The patch may reduce dependency on the compiler, but it doesn't mean it
reduces chance of race.

Consider your changes into __mm_populate() and populate_vma_page_range().
You put READ_ONCE() in both functions. But populate_vma_page_range() gets
called from __mm_populate(). Before your change compiler may optimize the
code and load from the memory once for a field. With your changes complier
will issue two loads.

It *increases* chances of the race, not reduces them.

The current locking scheme doesn't allow modifying VMA field without
down_write(mmap_sem).

We do have hacks[1] that try to bypass the limitation, but AFAIK we never
had a solid explanation why this should work. Sparkling READ_ONCE()
doesn't help with this, but makes it appears legitimate.

[1] I believe we also touch vm_flags without proper locking to set/clear
VM_LOCKED.

-- 
 Kirill A. Shutemov

