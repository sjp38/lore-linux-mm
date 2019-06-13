Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F8DCC31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:07:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F29AE215EA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:07:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="l8XwoOhr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F29AE215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99BCA6B0008; Wed, 12 Jun 2019 20:07:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94BF06B000E; Wed, 12 Jun 2019 20:07:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8130E6B0010; Wed, 12 Jun 2019 20:07:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 598216B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:07:11 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id l5so5669404oih.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:07:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Tkriq+76AVHAvWoxrGme0DZvQ0r/bAVgHuOCgkIGtnY=;
        b=ZAp//Utf38zOsbqn6MZxFrzzKmP9T++77Epx9u4SfGjHGMFxRpLExhT7pahzeeOIX+
         U6eq1ZebCp2zpdKYVooRYwILsn5DmuLEhhTmujQoOT8Q9k+hGTohTN1PIqJX6plwHGe+
         dOa8Y/4uWomofHiU3fExOGXkqghfGgBIQL2FKYW4GgYf+S90M74XXZUmQW96FdCzDy1u
         EfEOpFxzW4CN/SZjn7nWoQSI4QemBvQrmNwH/fbC1C5ODfSkpC55kYh/0ygrTIjeNPW6
         B2sjPDLnjqzPSUfD/CK7qPykgrDtvVx7pZYTk/3ZnQo6BmE2iwKgZtqoWV/KqXpxSgDa
         DTEg==
X-Gm-Message-State: APjAAAVpgNP6IeP8PeaUAxoCaxS/HmPZxQRM0DTN3fP83UtMxOT0xNsE
	jO1kUwG6lfyMkt1nm/XhL5WYJTHlG2UaikxggpO32ekSjBnTkpo6Xw/WqFMP+ezgBs6wxxwIqI0
	FIjZwdjYBx5iRdUSwRMXsfQgcmyoJtvCjyPUviu/SeYDQsu0ZSlxcgwc3QWappV41BQ==
X-Received: by 2002:aca:dcc2:: with SMTP id t185mr1232443oig.136.1560384430728;
        Wed, 12 Jun 2019 17:07:10 -0700 (PDT)
X-Received: by 2002:aca:dcc2:: with SMTP id t185mr1232419oig.136.1560384429963;
        Wed, 12 Jun 2019 17:07:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560384429; cv=none;
        d=google.com; s=arc-20160816;
        b=RveAD0qnofew6Y1bFW4K9Up/PLhfQqhhsjLaB4jsQmSDQjnVXOd7wRjCkaNcCs+cJ5
         /1E2Q2jGQar3DF3qAAqRDCGzTEJjDB9ZLyIVCBcsI+N2pU2lM40rPJ7p+60pf5zua9Ja
         SAq48Z+Feu+9mpxYV9u23TAWKyr2y+YxUTU9qBFY55zhsOpqRP+7/eB1TgRnTrs2OlEF
         n4hs3TEOglFREfwW6td7sid94tChnygmswcSN/JXoBzJzzBA6uylEwP/nYNF2pTwz2EM
         OC8xqFg+zQEyCWJfKyStoZSSw2mqpAt/3afbaktxECiO5pouRjQlwOCzD9SvOC5N0KY2
         IYyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Tkriq+76AVHAvWoxrGme0DZvQ0r/bAVgHuOCgkIGtnY=;
        b=ibjznPNpyZEy4/xbo39eJ/pOQbJzfVaAutdxAgrTz0PuSIEExQYJqq3jFnhWpyLiqY
         VGdTSMXqBZWqrk5NcYavreAqju9QcRhOKkx7zDm0F0gZQlHvCSqh858a9Gw5PCag8PK+
         T8+CFIJH66eDrWG6HR4rSa9GBQ1KOk02Gx0O8t2FMrW2/yo7kSB6R/OfX2DJfcyZ+0di
         0wVHxA7DITaUwGFxYFwLqEmRIF4WjF5kIS4poK+WYo2ajvrPMnaVBQISMTlu+3JZucTA
         Yoe5MyBSNLAMOZIcCfpuZrTVC+RAadMSbP1BCZDND4GASqrSHRgOysDfEorMuJsSjpEN
         4lFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=l8XwoOhr;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u185sor701063oia.144.2019.06.12.17.07.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 17:07:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=l8XwoOhr;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tkriq+76AVHAvWoxrGme0DZvQ0r/bAVgHuOCgkIGtnY=;
        b=l8XwoOhrF8eV64+8QPkXsyAB77xTxH5+1FeNQoAuo2IunkQvtG1vuCWbxf61GiESpY
         fQIRFrAiJkW+IrDOfUaKnJbZt9tIC32l6Xy4ybZd5y3ZF5SAN9+oleOeFWzdpXuE5tAV
         RC4eULNdvWPH93o14WsX9bo0OmW/YIpmbKuQu5yM5Yf06EOJ8i9vnZaZodDO+7FagV71
         Vn5z9fSnD8ksqLo4LFbc1Dao5jxA7SYmjVUULSHTYmYSmk2sRZLdxHWS6v14AiSxFZzW
         tg1S2yelMDIEm5tB1fuWa71m73rK7k/ukBJ9OjAtcguxhkgnJ/jKbGZv9vMCqeRRtAHT
         0UtQ==
X-Google-Smtp-Source: APXvYqw2VZtovLNG6JskbLITjxABP/AQIL/VRraLlLfxmhWXh1G3n3MX02RIzNA0cPbyuLQPJ9zagbpHOtrvb+hDjn0=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr1180994oih.73.1560384429638;
 Wed, 12 Jun 2019 17:07:09 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com> <1560376072.5154.6.camel@lca.pw>
In-Reply-To: <1560376072.5154.6.camel@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 17:06:57 -0700
Message-ID: <CAPcyv4hevCNgajrw7STXH4N5_heEOBz_-SzxcSB83DKDNacP9Q@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 2:47 PM Qian Cai <cai@lca.pw> wrote:
>
> On Wed, 2019-06-12 at 12:38 -0700, Dan Williams wrote:
> > On Wed, Jun 12, 2019 at 12:37 PM Dan Williams <dan.j.williams@intel.com>
> > wrote:
> > >
> > > On Wed, Jun 12, 2019 at 12:16 PM Qian Cai <cai@lca.pw> wrote:
> > > >
> > > > The linux-next commit "mm/sparsemem: Add helpers track active portions
> > > > of a section at boot" [1] causes a crash below when the first kmemleak
> > > > scan kthread kicks in. This is because kmemleak_scan() calls
> > > > pfn_to_online_page(() which calls pfn_valid_within() instead of
> > > > pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=n.
> > > >
> > > > The commit [1] did add an additional check of pfn_section_valid() in
> > > > pfn_valid(), but forgot to add it in the above code path.
> > > >
> > > > page:ffffea0002748000 is uninitialized and poisoned
> > > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > > > ------------[ cut here ]------------
> > > > kernel BUG at include/linux/mm.h:1084!
> > > > invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> > > > CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ #6
> > > > Hardware name: Lenovo ThinkSystem SR530 -[7X07RCZ000]-/-[7X07RCZ000]-,
> > > > BIOS -[TEE113T-1.00]- 07/07/2017
> > > > RIP: 0010:kmemleak_scan+0x6df/0xad0
> > > > Call Trace:
> > > >  kmemleak_scan_thread+0x9f/0xc7
> > > >  kthread+0x1d2/0x1f0
> > > >  ret_from_fork+0x35/0x4
> > > >
> > > > [1] https://patchwork.kernel.org/patch/10977957/
> > > >
> > > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > > ---
> > > >  include/linux/memory_hotplug.h | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > >
> > > > diff --git a/include/linux/memory_hotplug.h
> > > > b/include/linux/memory_hotplug.h
> > > > index 0b8a5e5ef2da..f02be86077e3 100644
> > > > --- a/include/linux/memory_hotplug.h
> > > > +++ b/include/linux/memory_hotplug.h
> > > > @@ -28,6 +28,7 @@
> > > >         unsigned long ___nr = pfn_to_section_nr(___pfn);           \
> > > >                                                                    \
> > > >         if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> > > > +           pfn_section_valid(__nr_to_section(___nr), pfn) &&      \
> > > >             pfn_valid_within(___pfn))                              \
> > > >                 ___page = pfn_to_page(___pfn);                     \
> > > >         ___page;                                                   \
> > >
> > > Looks ok to me:
> > >
> > > Acked-by: Dan Williams <dan.j.williams@intel.com>
> > >
> > > ...but why is pfn_to_online_page() a multi-line macro instead of a
> > > static inline like all the helper routines it invokes?
> >
> > I do need to send out a refreshed version of the sub-section patchset,
> > so I'll fold this in and give you a Reported-by credit.
>
> BTW, not sure if your new version will fix those two problem below due to the
> same commit.
>
> https://patchwork.kernel.org/patch/10977957/
>
> 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed the same
> pfn_section_valid() check.

All online memory is to be onlined as a complete section, so I think
the issue is more related to vmemmap_populated() not establishing the
mem_map for all pages in a section.

I take back my suggestions about pfn_valid_within() that operation
should always be scoped to a section when validating online memory.

>
> 2) powerpc booting is generating endless warnings [2]. In vmemmap_populated() at
> arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> PAGES_PER_SUBSECTION, but it alone seems not enough.

On PowerPC PAGES_PER_SECTION == PAGES_PER_SUBSECTION because the
PowerPC section size was already small. Instead I think the issue is
that PowerPC is partially populating sections, but still expecting
pfn_valid() to succeed. I.e. prior to the subsection patches
pfn_valid() would still work for those holes, but now that it is more
precise it is failing.

