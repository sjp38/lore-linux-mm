Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05417C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E4DA206B6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:47:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E4DA206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16F846B0007; Tue, 16 Apr 2019 12:47:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F6C36B0008; Tue, 16 Apr 2019 12:47:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED9A36B000A; Tue, 16 Apr 2019 12:47:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BABB6B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:47:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e22so9635631edd.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OquYvDAVNcaD19ZiuLo0WwiU698DJ7uwfFYxisr8j+E=;
        b=BFK1qR0b1wDZ9Xp7Vig1lpmQIw+EHbBImoUo5D8Jz4NzsSJm2WXM6qYiudLLeObCz8
         1HJH1n50XP30ViH/4CLFA9kq7iJGfmznab0i7jiQTxz31erOumghFiBn0VdLhe/gdlhI
         LyYlSBmuhsWpfu891G7cAkwDehkaMDWFVUN8QR3cQ7yi71i+HB4BFkUUigLl6LiIvG1x
         LsL/n6bWS6B8TV4m78eS0jTb0dvBvIZIZyagq1Z5qVkY2zclkM4tyNMrng/mBTeb4JlC
         YejMPNPaKyWvlSoA8S/lRQ/MrgaKNHtJJXydqHfdA09a90UjpKOdGHS0Le49v4ZH7jI6
         P9MA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVklkJ67WU4Hmre4OxqEeGkmYHugApQaRyKdwFEjgyqZ6aDjdk0
	LbUjuC47Kx5kKyOYkwWQdxuWsI4yCoAQKfUaCvmcsnf6JiQIxn6xDE7c69IMaEcl7/kKeech7MG
	BDR3Lj9O0Sym2kcalYI1XHJUh3LtXoTioIYI8UWuzE+w66tGMPAz4LdyKUbXuTkVSAA==
X-Received: by 2002:aa7:c5ca:: with SMTP id h10mr39355886eds.140.1555433221150;
        Tue, 16 Apr 2019 09:47:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwi+AD1/aBb8dKX3+zRHl0aVjKPinwZz6Db5VT6/JCeoWfsdGS5M2wmOJtfxw2sDRrn9GeQ
X-Received: by 2002:aa7:c5ca:: with SMTP id h10mr39355811eds.140.1555433220062;
        Tue, 16 Apr 2019 09:47:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555433220; cv=none;
        d=google.com; s=arc-20160816;
        b=LTt5y5/JcAshIu1YuBKhzEpm6s6/VUrfsnbhFq/BbIs01zvJJvzSj8areSDtR0vjrA
         sHKbgev2LNnn+2bTp7b0IXw1JIVkaHHMRzjdPXs78K0rPW1Q/zpdNS+UjUZkH/ZVwpPJ
         CERhlTQNcEeyM/uP9kBDcBjT2Yerfe2qc9FcE0yAfbkzcx94PA2tfT/wmTDxtj6NDSXF
         Hl41sszEaH9o3RcbrU/gKKhJvGX/OuEunS+pZ/X+dQc8lj2Uig2zT0GUbUw55SCRCu9m
         nN0fSiysmFdDRurOIpscc9aF1Yw+jiiiq0NtODC4DZ/EYc/5MF+QGy0a2FnqTvh7GviD
         aCPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=OquYvDAVNcaD19ZiuLo0WwiU698DJ7uwfFYxisr8j+E=;
        b=y9QWpAE0oiD/Y/gI+LaOAVpG0pifF+SoLf9H3LQ34+Z4v/5tKxnPFNS2ivBvAbglbP
         qBerCul7ARNu5ciidpVPqSiT/NzWuULOm0VKK1we0pYIixOdGvz+q/7eeIivSH4+zb+E
         Uk6FM7D83UtJW42DLZ/sQCxO7zV/tEWpVMnYp742tVA8/HrilqXKBjs2vPLeiNq64xZE
         8SdAAek1aHb4rh3EQlMR0+/T0/VLIHKhUejqqbuGkzQqBQgZ4ujfjzRjfjkiQ0firogp
         mcNogPEZLKcxwzfLMMNLaF/rjPSe82hVHerUMb6kU3QXtJ1z7vMAw9ZWVlZLCmPDX+pS
         aKFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lw19si5952277ejb.187.2019.04.16.09.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 09:46:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3126AAAC3;
	Tue, 16 Apr 2019 16:46:59 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id A0DBB1E15B4; Tue, 16 Apr 2019 18:46:58 +0200 (CEST)
Date: Tue, 16 Apr 2019 18:46:58 +0200
From: Jan Kara <jack@suse.cz>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 10/15] block: add gup flag to
 bio_add_page()/bio_add_pc_page()/__bio_add_page()
Message-ID: <20190416164658.GB17148@quack2.suse.cz>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
 <20190415145952.GE13684@quack2.suse.cz>
 <20190415152433.GB3436@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190415152433.GB3436@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-04-19 11:24:33, Jerome Glisse wrote:
> On Mon, Apr 15, 2019 at 04:59:52PM +0200, Jan Kara wrote:
> > Hi Jerome!
> > 
> > On Thu 11-04-19 17:08:29, jglisse@redhat.com wrote:
> > > From: Jérôme Glisse <jglisse@redhat.com>
> > > 
> > > We want to keep track of how we got a reference on page added to bio_vec
> > > ie wether the page was reference through GUP (get_user_page*) or not. So
> > > add a flag to bio_add_page()/bio_add_pc_page()/__bio_add_page() to that
> > > effect.
> > 
> > Thanks for writing this patch set! Looking through patches like this one,
> > I'm a bit concerned. With so many bio_add_page() callers it's difficult to
> > get things right and not regress in the future. I'm wondering whether the
> > things won't be less error-prone if we required that all page reference
> > from bio are gup-like (not necessarily taken by GUP, if creator of the bio
> > gets to struct page he needs via some other means (e.g. page cache lookup),
> > he could just use get_gup_pin() helper we'd provide).  After all, a page
> > reference in bio means that the page is pinned for the duration of IO and
> > can be DMAed to/from so it even makes some sense to track the reference
> > like that. Then bio_put() would just unconditionally do put_user_page() and
> > we won't have to propagate the information in the bio.
> > 
> > Do you think this would be workable and easier?
> 
> It might be workable but i am not sure it is any simpler. bio_add_page*()
> does not take page reference it is up to the caller to take the proper
> page reference so the complexity would be push there (just in a different
> place) so i don't think it would be any simpler. This means that we would
> have to update more code than this patchset does.

I agree that the amount of work in this patch set is about the same
(although you don't have to pass the information about reference type in
the biovec so you save the complexities there). But for the future the
rule that "bio references must be gup-pins" is IMO easier to grasp for
developers and you can reasonably assert it in bio_add_page().

> This present patch is just a coccinelle semantic patch and even if it
> is scary to see that many call site, they are not that many that need
> to worry about the GUP parameter and they all are in patch 11, 12, 13
> and 14.
> 
> So i believe this patchset is simpler than converting everyone to take
> a GUP like page reference. Also doing so means we loose the information
> about GUP kind of defeat the purpose. So i believe it would be better
> to limit special reference to GUP only pages.

So what's the difference whether the page reference has been acquired via
GUP or via some other means? I don't think that really matters. If say
infiniband introduced new ioctl() that takes file descriptor, offset, and
length and just takes pages from page cache and attaches them to their RDMA
scatter-gather lists, then they'd need to use 'pin' references anyway...

Then why do we work on differentiating between GUP pins and other page
references?  Because it matters what the reference is going to be used for
and what is it's lifetime. And generally GUP references are used to do IO
to/from page and may even be controlled by userspace so that's why we need
to make them different. But in principle the 'gup-pin' reference is not about
the fact that the reference has been obtained from GUP but about the fact
that it is used to do IO. Hence I think that the rule "bio references must
be gup-pins" makes some sense.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

