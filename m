Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B6EC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 17:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36D6920850
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 17:11:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SQ0N0+1F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36D6920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6AB46B05C6; Mon, 26 Aug 2019 13:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1BC36B05C7; Mon, 26 Aug 2019 13:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B09096B05C8; Mon, 26 Aug 2019 13:11:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 915506B05C6
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:11:12 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3A8D2180AD801
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 17:11:12 +0000 (UTC)
X-FDA: 75865219584.27.trick05_44a8c2f441e2c
X-HE-Tag: trick05_44a8c2f441e2c
X-Filterd-Recvd-Size: 7204
Received: from mail-vs1-f68.google.com (mail-vs1-f68.google.com [209.85.217.68])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 17:11:11 +0000 (UTC)
Received: by mail-vs1-f68.google.com with SMTP id q188so11476051vsa.4
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:11:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4cqvk2rMJ0foC4cwOoJDTAFH/gscagauUiEQAyz91BU=;
        b=SQ0N0+1FDzqm6PcclK6RDsfrI7U7yhfJhWvx43h29EvQBZyhStsNUpg57BS7oW0JlX
         XpZEn9kSWvTKl/0Y13sXpk5SAlBcT2Jp+sjtooudQmVjtgkk3gCVEHw5GIKmIZKbig49
         Cy3wNsypCKml0mRALlbfsD8SA7sDV5LwVgp/dAk5D4RvEtJec0xagPN8UrjTrhfTSh54
         uSSNYg7GNe5aAM3CaSUur7TGncXdlWULIMnaQaZ123CLJKWfAHfLxqT3p5dI4C3d8p1y
         Of6oS3nc8gsoOKRel24tt1GYYcjcPEcoxOvcBrXKzYZyhn/n0yuSjuhFTbk8HZ0VnQIP
         iV/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=4cqvk2rMJ0foC4cwOoJDTAFH/gscagauUiEQAyz91BU=;
        b=RT59zIv4oV+w9vcsWi43HjE+ES8MqUzds7OBAzYWDyKARFu1AM1iGasLOo3W1unch4
         aMAYVu4pWQW7qfFCqR67KX7Z92+Mnb1PDujQrW25P5Ag8uMVHmLnX9+CsfA0iAK1zI2a
         /3XzawbPmx4p+TMNYwNmKo0SClwqBesaGmYGaQrdNRuLO6q4bswo2HRu1kZbnYTve4Lu
         /JzwSf3DTeFwA78mpjG27In2iMLWw6zA66e/e6kzBoNL68CFrdteFcFB1iwDJBxKH3d7
         Fif77BkO8Dg7mT0te1egC/PwxMSNTQi8xfKxjt3rCHPlgfsRBpsaii22K2oscsjtCrIU
         zYxw==
X-Gm-Message-State: APjAAAU1Uc6wwxv5u4/rhLl5pf/IRNMtrNFWZXvjMoYKW7EAKr/8f7f6
	AOQZrNAvTtBoC547gNNpF2iMllNE0MxZAc7uOBBbAg==
X-Google-Smtp-Source: APXvYqwU52d3URyQy8P4/M/m/gC0/Q8W9RRHuHfMLOPTvfV1QTwj+hy1lfMaJLto+SsxKcyW/UNaHBu69zxw8zIaGUM=
X-Received: by 2002:a67:e45a:: with SMTP id n26mr10762169vsm.94.1566839470991;
 Mon, 26 Aug 2019 10:11:10 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo56W1JGOc6w-NAf-hyWwJQ=vEDsAVAkO8MLLJBpQ0FTAcA@mail.gmail.com>
 <20190822130219.GK12785@dhcp22.suse.cz> <CACDBo57oFDEYY-GR1NEZEXKS409BkEx+RYywMNwuUn5f5Sz76A@mail.gmail.com>
 <20190826072526.GC7538@dhcp22.suse.cz>
In-Reply-To: <20190826072526.GC7538@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Mon, 26 Aug 2019 22:41:03 +0530
Message-ID: <CACDBo541V4Od02i82LNp7ip3oeH1kHw4OWxGBV3G9qi4zsPvkw@mail.gmail.com>
Subject: Re: How cma allocation works ?
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 12:55 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 23-08-19 00:17:22, Pankaj Suryawanshi wrote:
> > On Thu, Aug 22, 2019 at 6:32 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 21-08-19 22:58:03, Pankaj Suryawanshi wrote:
> > > > Hello,
> > > >
> > > > Hard time to understand cma allocation how differs from normal
> > > > allocation ?
> > >
> > > The buddy allocator which is built for order-N sized allocations and it
> > > is highly optimized because it used from really hot paths. The allocator
> > > also involves memory reclaim to get memory when there is none
> > > immediatelly available.
> > >
> > > CMA allocator operates on a pre reserved physical memory range(s) and
> > > focuses on allocating areas that require physically contigous memory of
> > > larger sizes. Very broadly speaking. LWN usually contains nice writeups
> > > for many kernel internals. E.g. quick googling pointed to
> > > https://lwn.net/Articles/486301/
> > >
> > > > I know theoretically how cma works.
> > > >
> > > > 1. How it reserved the memory (start pfn to end pfn) ? what is bitmap_*
> > > > functions ?
> > >
> > > Not sure what you are asking here TBH
> > I know it reserved memory at boot time from start pfn to end pfn, but when
> > i am requesting memory from cma it has different bitmap_*() in cma_alloc()
> > what they are ?
> > because we pass pfn and pfn+count to alloc_contig_range and pfn is come
> > from bitmap_*() function.
> > lets say i have reserved 100MB cma memory at boot time (strart pfn to end
> > pfn) and i am requesting allocation of 30MB from cma area then what is pfn
> > passed to alloc_contig_range() it is same as start pfn or
> > different.(calucaled by bitmap_*()) ?
>
> I am not deeply familiar with the CMA implementation but from a very
> brief look it seems that the bitmap simply denotes which portions of the
> reserved area are used and therefore it is easy to find portions of the
> requested size by scanning it.
> okay
> > > Have you checked the code? It simply tries to reclaim and/or migrate
> > > pages off the pfn range.
> > >
> > What is difference between migration, isolation and reclamation of pages ?
>
> Isolation will set the migrate type to MIGRATE_ISOLATE, btw the comment
> in the code I referred to says this:
>  * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
>  * the range will never be allocated. Any free pages and pages freed in the
>  * future will not be allocated again. If specified range includes migrate types
>  * other than MOVABLE or CMA, this will fail with -EBUSY. For isolating all
>  * pages in the range finally, the caller have to free all pages in the range.
>  * test_page_isolated() can be used for test it.
>
> Reclaim part will simply drop all pages that are easily reclaimable
> (e.g. a clean pagecache) and migration will move existing allocations to
> a different physical location + update references to it from other data
> structures (e.g. page tables to point to a new location).


Okay Thanks michal, now it will easy to understand.
>
>
>
> > > > 5.what isolate_migratepages_range(), reclaim_clean_pages_from_list(),
> > > >  migrate_pages() and shrink_page_list() is doing ?
> > >
> > > Again, have you checked the code/comments? What exactly is not clear?
> > >
> > Why again migrate_isolate_range() ?
> > (reclaim_clean_pages_fron_list) if we are reclaiming only clean pages then
> > pages will not contiguous ? we have only clean pages which are not
> > contiguous ?
>
> reclaim_clean_pages_from_list is a simple wrapper on top of shrink_page_list.
> It simply takes clean page cache pages to reclaim it because that might
> be less expensive than migrating that memory.
> okay
> > What is work of shrink_page_list() ?
>
> This is a core of the memory reclaim. It unmaps/frees pages and try to
> free them.
> okay
> > please explain all flow with taking
> > one allocation for example let say reserved cma 100MB and then request
> > allocation of 30MB then how all the flow/function will work ?
>
> I would recommend to read the code carefully and following the git
> history of the code is very helpful as well. This is not a rocket
> science, really.
hahaha rocket science !!! I think linux memory management should be
part of rocket science.
>
> --
> Michal Hocko
> SUSE Labs

