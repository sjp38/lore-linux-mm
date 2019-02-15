Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7007FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 20:29:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2319620823
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 20:29:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="W1EkMPd+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2319620823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B50DA8E0003; Fri, 15 Feb 2019 15:29:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B002C8E0001; Fri, 15 Feb 2019 15:29:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A17678E0003; Fri, 15 Feb 2019 15:29:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 607528E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 15:29:00 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id k14so7693713pls.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:29:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RfJTwQxNtAt3SGNUAeeBsgYvXmANCdHsJDtsXuMeyS8=;
        b=gsRoT1GDAXH8vQeS3pE0lCVeTJMbo+TBZ3h/U6HjWg8/W5U1jDWKugZKl6yikBbCm8
         ysayh0lHfAg4oCo3YP2SBlL5LGSIQj+gF2KAmkLXghcww/r9nlUSNLSimXi8pKHi2H5s
         SlFT4QWBvkxmJxVp/fQuVMDDKsLjwaO0+kG8xOSrgcd0XOuVVlGdVUA0Yy3SaTKMVURl
         GT04dX1b3hq6C9wB7bKmKWMhdxK6Y66op0BHswt0AfYdTNBFhfxWsm4B5jWOvbKMnVhU
         G6jgy3+wgUELP66ohbQ+VmxNwUvGns1TC9juMCyJBWp3cKGvDtS/tZFykfpnDpqGC4np
         jveQ==
X-Gm-Message-State: AHQUAuaDGC9GcT/0L4nXCSAg66Tbxa2fCVZEvO2z4qLQ9CK/kMt3xZ0l
	MqogsPhpRVnxynXfmdGBp+YnfJwW6uMvX26vLrJb8LvfL27WwQglhVEY/aPzID7i/D5uU8LcXb1
	GOXB6kb3fxBnFXAhsNcUpZNL0n5lMP5U2gwyC20D2Qmfznbc0+a99OUf4gfsQzgg96w==
X-Received: by 2002:a17:902:7683:: with SMTP id m3mr12091260pll.191.1550262540081;
        Fri, 15 Feb 2019 12:29:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYTyXtDniC6sudbWdZqSeBibLvrVvLMqzcJ3auk68PDsYWjgjdUerQUFz/fLu9evqwxActE
X-Received: by 2002:a17:902:7683:: with SMTP id m3mr12091197pll.191.1550262539389;
        Fri, 15 Feb 2019 12:28:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550262539; cv=none;
        d=google.com; s=arc-20160816;
        b=i5h4e+nQnB9S43Byo0phe886sJeBcqhh9Jl08u+mwNk6ae3whdmpOOwTXFgrwEHKmN
         FP2JkpX4wbQ1gwiUzy3oWNl9HYg/tvmcG0n0XOlUQXUo2OCC3hvl+UhOzL8BqKKeCbnI
         8In64Y9Ari4xAgY8t8ah/EnjiOuLvLa8+HM886iq/CkJZRAFls9TZveTnBqwXDcFfNPX
         8JLQ6cynVTJFL/VABnphFP/TKEmX2Kaoxihbe+4ibZ5vTVDLh9mm7Mv8gD+yXTj5k/Em
         /4zpDxMEoK1+oHnPaK0+erE9ewodnR8w8i+ci0HMzGGe0sazB2ftdCTbH49+yHbebD2g
         2nfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RfJTwQxNtAt3SGNUAeeBsgYvXmANCdHsJDtsXuMeyS8=;
        b=LTJX5VCZDfA/S5q0xar8whAJ8iFgDJpl7cyK/GMry442O7TmBxe/Nhs+exr3PLTvwy
         0dsXRGSFhxk6IieOkNB7ZIl/WEXt1zFR+2ngJe2QozRVnKEQscbKGJ3PO4/AN6FyZvvT
         v7zHMorh3oXlp+AseP9cBKefaglATaiNE16skVPAPPbf64p+Dx7ilipp6LyRORkBha4K
         iCTOT09bOH3LRXjOJKjV8rWhJORMrVx+1vVBCycSLVjo8pum6tsPlYOuVFxezhUyYbSQ
         uAYJf1ILNJ/nYSYN+gYGpPYC+JMdlPVdNxmXqCcPSFB7C/Flk39XfwayGGZyvTgpaohz
         X6pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W1EkMPd+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bc7si6453200plb.120.2019.02.15.12.28.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 12:28:59 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W1EkMPd+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RfJTwQxNtAt3SGNUAeeBsgYvXmANCdHsJDtsXuMeyS8=; b=W1EkMPd+0mkWguf2uAGeMdTk3
	kZDkDxRdVsxC4bMDWDO/dB6wLusOvD4FSMkOajm/mzZCMr4eRc0QdIhOitulAZ0i+XxsGbICEUzsF
	8SYRg2eBxldECz8EjvYHs3DIHmiyAhMqr0ZayB0sutHedapn1CnACbAus6JToj2ZUdkN0IzzpLGVY
	+L5Z5Ey2VLTT0jd3j/yIAV/AZosDGDfaYDWucu78zkdEFazU32lalN2iDO60DNBh5wAIeL6nYJFsT
	jmPMJNvC5jyogYRq8H+ygQwIeambm5Myf3CiPc9VDy8QroKcuf+hLTzR2FwjC4hEs3PbAVsoIXG1G
	a1xMriBPg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guk6U-0001Xm-AK; Fri, 15 Feb 2019 20:28:58 +0000
Date: Fri, 15 Feb 2019 12:28:58 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190215202858.GL12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214222944.74ipvbnvo2lvfgnr@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214222944.74ipvbnvo2lvfgnr@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:29:44AM +0300, Kirill A. Shutemov wrote:
> On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Feb 12, 2019 at 10:34:54AM -0800, Matthew Wilcox wrote:
> > > Transparent Huge Pages are currently stored in i_pages as pointers to
> > > consecutive subpages.  This patch changes that to storing consecutive
> > > pointers to the head page in preparation for storing huge pages more
> > > efficiently in i_pages.
> > > 
> > > Large parts of this are "inspired" by Kirill's patch
> > > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> > > 
> > > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > 
> > I believe I found few missing pieces:
> > 
> >  - page_cache_delete_batch() will blow up on
> > 
> > 			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> > 					!= pvec->pages[i]->index, page);
> > 
> >  - migrate_page_move_mapping() has to be converted too.
> 
> Other missing pieces are memfd_wait_for_pins() and memfd_tag_pins()
> We need to call page_mapcount() for tail pages there.

@@ -39,6 +39,7 @@ static void memfd_tag_pins(struct xa_state *xas)
        xas_for_each(xas, page, ULONG_MAX) {
                if (xa_is_value(page))
                        continue;
+               page = find_subpage(page, xas.xa_index);
                if (page_count(page) - page_mapcount(page) > 1)
                        xas_set_mark(xas, MEMFD_TAG_PINNED);
 
@@ -88,6 +89,7 @@ static int memfd_wait_for_pins(struct address_space *mapping)
                        bool clear = true;
                        if (xa_is_value(page))
                                continue;
+                       page = find_subpage(page, xas.xa_index);
                        if (page_count(page) - page_mapcount(page) != 1) {
                                /*
                                 * On the last scan, we clean up all those tags

