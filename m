Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89F0DC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EF94218B0
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:27:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EF94218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D48D66B0003; Fri,  2 Aug 2019 04:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF84A6B0006; Fri,  2 Aug 2019 04:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE8256B000A; Fri,  2 Aug 2019 04:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 710FB6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:27:57 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v14so36631423wrm.23
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kxLspLVHA6vSyXycZU6NpZlLe737X3m3PwChsrnCDtw=;
        b=VqsTD1ZzuG2stCk+aBDxCfKYQORNZnHK+K2/QWk9IMUIniH86GF3Puy9UIndz32T9f
         MU4Ig4J/Ul6vlxQXUlyUmmrHPuKzGN+G6yamgsjKdocA/kgV1iYV5BlNE/7viDFPkLOc
         dU8i3KUYhQN25Kv80BzhrEbpPblJjmJQNKOd53k+/6mW2sHnGyZGWMKBSuRDzFok43dV
         ogz/4YEGdpWmFrF8wWGAmC2GSUYgU8AynqEjwxBtIOLXF4GT6RSKhB5ACf3sercxLg92
         sB6kN0qYhL8MZK7V/vc2305rRMTHDVmVuhJW7mDTHyQg568ahqL43h3NKlvuKWGanO2x
         tVjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUsMqPzvO97669VsHEsrF7+e1hA9ls83vRJnz80nOpXCTdYq5nI
	JtZ5gcCnSz6dCRkb8BEXgsQ7zWu8U57aPx95qN8KLY+bzmnPE3/HvUX9jm7ShursHSpA9erEON8
	7Q/nGzwq7G3BLId3dsyw6Jo1Trnyn6QA+6dJAywSURFgRVQi+E9D9jSgJQHg138+ybw==
X-Received: by 2002:a1c:44d7:: with SMTP id r206mr3375836wma.164.1564734477007;
        Fri, 02 Aug 2019 01:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3qSMuxouXXXO3g1NISQfzH3q8zNK5Tw15+ROVDvRgy2jaZMno2+CyC6sRU1NdknifOYUp
X-Received: by 2002:a1c:44d7:: with SMTP id r206mr3375764wma.164.1564734475954;
        Fri, 02 Aug 2019 01:27:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564734475; cv=none;
        d=google.com; s=arc-20160816;
        b=Ew4tQci2mOEQTOIjYrbrY0eDok+Vl2ZtBDJVfTBXR259SbjHrDYNHWd8aTDU/uUkoc
         VAcLO6iQfDScDnv2WR9W+VKZ3wboh57BMGSYHMG9Jb3Dr0QcdbuATb2szWhczt+wyEqP
         abu4i+jbPiLTNflkXkiP9B6ysOmnD5mj+qDiNDyACMBofA8V6/fQUwV41LcD//U1XuHt
         RCCxqwOFXCSDCAWcsSUovP8ElZUGmWpvM8H8yAqbxzSNCfRXAE4/Tna4ga+GYlBLRR2y
         rxF5dVSyyWLa2e74xmhujnYoYXnSC3AQcRbMlrqICsgtG0T9feBj2XhEZF89F0FKVsV0
         Ulng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kxLspLVHA6vSyXycZU6NpZlLe737X3m3PwChsrnCDtw=;
        b=vVMxcH3iYfh+4ZaabXBWDkk2cjBJDe65eImMthQ0m1C+2MO9xqBusBed0Y+9X50Wch
         /5yY8KjoS1p+SDuxAFrUpdOh9S+9lMMzet3T4bX2zSMIJbXKmMLYEfGkxsdgm4zbed77
         Ofj6gzpk5lickusCiCAAKyMqrftfOxL+5MaGkRX2/erUvOuosnf8jx5ApzwJIopej9rY
         1CevRtwHZLkBrpRMqYpn4mgwCA/jHc9BeNq3l12HZ+s0IPyQCYixk1lXZrFBY94EWG2C
         677ChOcinq7GODYo67tmv0HB5zxv/XQmEQLxLMkZDh5y3+gY2l7jLnU9r82dfnkL+wbQ
         xN8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u11si66713848wrw.391.2019.08.02.01.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 01:27:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6415A68C65; Fri,  2 Aug 2019 10:27:53 +0200 (CEST)
Date: Fri, 2 Aug 2019 10:27:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>,
	linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 1/2] iomap: Support large pages
Message-ID: <20190802082753.GA10664@lst.de>
References: <20190731171734.21601-1-willy@infradead.org> <20190731171734.21601-2-willy@infradead.org> <20190731230315.GJ7777@dread.disaster.area> <20190801035955.GI4700@bombadil.infradead.org> <20190801162147.GB25871@lst.de> <20190801174500.GL4700@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801174500.GL4700@bombadil.infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 10:45:00AM -0700, Matthew Wilcox wrote:
> On Thu, Aug 01, 2019 at 06:21:47PM +0200, Christoph Hellwig wrote:
> > On Wed, Jul 31, 2019 at 08:59:55PM -0700, Matthew Wilcox wrote:
> > > -       nbits = BITS_TO_LONGS(page_size(page) / SECTOR_SIZE);
> > > -       iop = kmalloc(struct_size(iop, uptodate, nbits),
> > > -                       GFP_NOFS | __GFP_NOFAIL);
> > > -       atomic_set(&iop->read_count, 0);
> > > -       atomic_set(&iop->write_count, 0);
> > > -       bitmap_zero(iop->uptodate, nbits);
> > > +       n = BITS_TO_LONGS(page_size(page) >> inode->i_blkbits);
> > > +       iop = kmalloc(struct_size(iop, uptodate, n),
> > > +                       GFP_NOFS | __GFP_NOFAIL | __GFP_ZERO);
> > 
> > I am really worried about potential very large GFP_NOFS | __GFP_NOFAIL
> > allocations here.
> 
> I don't think it gets _very_ large here.  Assuming a 4kB block size
> filesystem, that's 512 bits (64 bytes, plus 16 bytes for the two counters)
> for a 2MB page.  For machines with an 8MB PMD page, it's 272 bytes.
> Not a very nice fraction of a page size, so probably rounded up to a 512
> byte allocation, but well under the one page that the MM is supposed to
> guarantee being able to allocate.

And if we use GB pages?

Or 512-byte blocks or at least 1k blocks, which we need to handle even
if they are not preferred by any means.  The real issue here is not just
the VMs capability to allocate these by some means, but that we do
__GFP_NOFAIL allocations in nofs context.

> > And thinking about this a bit more while walking
> > at the beach I wonder if a better option is to just allocate one
> > iomap per tail page if needed rather than blowing the head page one
> > up.  We'd still always use the read_count and write_count in the
> > head page, but the bitmaps in the tail pages, which should be pretty
> > easily doable.
> 
> We wouldn't need to allocate an iomap per tail page, even.  We could
> just use one bit of tail-page->private per block.  That'd work except
> for 512-byte block size on machines with a 64kB page.  I doubt many
> people expect that combination to work well.

We'd still need to deal with the T10 PI tuples for a case like that,
though.

> 
> One of my longer-term ambitions is to do away with tail pages under
> certain situations; eg partition the memory between allocatable-as-4kB
> pages and allocatable-as-2MB pages.  We'd need a different solution for
> that, but it's a bit of a pipe dream right now anyway.

Yes, lets focus on that.  Maybe at some point we'll also get extent
based VM instead of pages ;-)

