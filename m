Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10582C46470
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2F19206BB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:41:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="fcpRnCrY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2F19206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 594F06B027A; Thu,  6 Jun 2019 11:41:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 545996B027C; Thu,  6 Jun 2019 11:41:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43D346B027D; Thu,  6 Jun 2019 11:41:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 203286B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:41:32 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id b7so2297608qkk.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:41:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0i1aFTdOJpXWn0n3eufS+vd8tfTLEg4kM4eYWLAkurQ=;
        b=pV+bijNbGo3rlAZ3A7KWkbGpYmA16GkbAyWLaZLG/Ag47z3kk08NVEfzg9hI7xDbva
         iCv21K13Rhgvu0uhax1oOSEAjtZQ+ATpUyxl+I9IusC6cIHB4T9MyEWmspF36qVwkOSX
         hihWFwPf+UMiMYM17QChVvNHbBdyHZsuynCjFcvEFrFOsoVbaJQSSbY1jy/KFBuUUXtB
         eMJ4si0DDscFmQ06g1sa09HnrI/TBKGb0duwirtPPdwoaNJNUawq9ZipLNy7ydD9YO9X
         fWcQaUDI1hLWQC+K4rRpUtYhoaSooQLNTiUc4g3AWx+JqXJ992J5OK4+YkWStDAUZuXF
         6bsg==
X-Gm-Message-State: APjAAAX5c9xpBCkJMWY63TczHKqrBzoczkb4MzNNGsR2ZEW3KXL+XdaQ
	8fdCOF3HFfLP4UzuoMquIstA6PkYT6bHhYwocUu5OCUmUtBlaPGfO5bUcgJaztvEzfiGJimNmzm
	n06FEnXyhOREL3ro/rGqHtGuy4UuDrRB126Q9pWTwAPbA01Qk7gEn3Y45Z6qk9WLhiw==
X-Received: by 2002:a37:783:: with SMTP id 125mr39081667qkh.0.1559835691821;
        Thu, 06 Jun 2019 08:41:31 -0700 (PDT)
X-Received: by 2002:a37:783:: with SMTP id 125mr39081606qkh.0.1559835691102;
        Thu, 06 Jun 2019 08:41:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559835691; cv=none;
        d=google.com; s=arc-20160816;
        b=ScYtG/Ubr/vcc7T1dvDI4oJaUEBIUdSsKk0Px7JXRFRDCblhfz/zkdL+EZFG2cvZuW
         AINIs1l9nEQuNH5r6tgHXFY4r1XWz8pbOH+aMEIo98gVpQ1ZwPL3aZpgJ67wPOcxRLDa
         bIKFptzTILsgegfvVUcQwhJK3vP7IOinJIppy+fK5sNkrNCQ+idPXBiSx9WPXPGOWTp5
         4AAbL5V5W7bfjN2VvlUlFnly1jAfX4GEtkoQhZeG7eztybdD369RfTHr/8lCY1CIdoGI
         c+afRaL5CMrgqThMSNF8Y+tsKgwFWmEuvqHwrKZr++qhUfRmZhE3C2ljUx3pWz/XfVLH
         Wxww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=0i1aFTdOJpXWn0n3eufS+vd8tfTLEg4kM4eYWLAkurQ=;
        b=YXtRRDyHYxE3R/h1u6P1B+XltCTpuD8rQtSDiVX6jMWirVlFRgbUBDVde7qSTtC1Ub
         4fUzC5XXl38zYZ9lWZIqwWU5RvT6kpGEuTLyfEcFQg/gTZOiEYNyqCASKFcGTfnFnWM0
         XOytiiF2JkG/q9+9Vt8K7iKnqcJqeI69lWLB1kKGU+boLFnNhZ/j6dOzTFCGlnpkVy99
         7YRpNx7yaTAf/a6kVRUi7WVSzOUxdm/oRPR1RphSF7/Z0LTD/tufwcT1SozDLe/79qni
         Wo71NLBX4+8p9LHSM5q17wEsP+imT36iqA8xAjlt3uNPPhC40dGAB3BxCWTghv6Jr6Cq
         jQ0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fcpRnCrY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w45sor1711338qvc.66.2019.06.06.08.41.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 08:41:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fcpRnCrY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=0i1aFTdOJpXWn0n3eufS+vd8tfTLEg4kM4eYWLAkurQ=;
        b=fcpRnCrYaBVTFoUsjFrU4nfFBb5bqplCkC1v+c+D+pV0u1F72fEYtbFQkVqkMLANoR
         Xbid6lttcAVxdlkC1UhtQl1RJNCsagZXAkTV3No06Pv8HZe4owh3VDE2oSNncB3ekVgJ
         hHc8cy42aOo0ECE5s/A/Z4wD5MXIO1h0JxBIUqaXWUTWUcicwJ6jaxn81OaEHTX/MMPf
         XMy6H4vMSPJb6D0NjTzfYeMH/4oWbOGosoVrBwo7TELk60D8sRMgtGEP0hU5ruSxkWqM
         B+Ia/sasVC+CPLVbK47UrIXmeD0tFqa7rI7904J9fhlTmBN/A/2JqzEv7VLhJqDSm5OX
         oIiw==
X-Google-Smtp-Source: APXvYqxMF4qP1KcCMGw1eGVyz6lzlbQ3BfQnSWCE38FzzUEbJVC/lu9fEaga/Qnkbc8B94TR70yFiQ==
X-Received: by 2002:a0c:ed4b:: with SMTP id v11mr38368417qvq.126.1559835690779;
        Thu, 06 Jun 2019 08:41:30 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y129sm1077882qkc.63.2019.06.06.08.41.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 08:41:30 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYuW9-0003PU-VS; Thu, 06 Jun 2019 12:41:29 -0300
Date: Thu, 6 Jun 2019 12:41:29 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
Message-ID: <20190606154129.GB17373@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-3-rcampbell@nvidia.com>
 <20190606141644.GA2876@ziepe.ca>
 <20190606142743.GA8053@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190606142743.GA8053@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 10:27:43AM -0400, Jerome Glisse wrote:
> On Thu, Jun 06, 2019 at 11:16:44AM -0300, Jason Gunthorpe wrote:
> > On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
> > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > 
> > > There are no functional changes, just some coding style clean ups and
> > > minor comment changes.
> > > 
> > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > > Cc: Matthew Wilcox <willy@infradead.org>
> > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > >  include/linux/hmm.h | 71 +++++++++++++++++++++++----------------------
> > >  mm/hmm.c            | 51 ++++++++++++++++----------------
> > >  2 files changed, 62 insertions(+), 60 deletions(-)
> > 
> > Applied to hmm.git, thanks
> 
> Can you hold off, i was already collecting patches and we will
> be stepping on each other toe ... for instance i had

I'd really rather not, I have a lot of work to do for this cycle and
this part needs to start to move forward now. I can't do everything
last minute, sorry.

The patches I picked up all look very safe to move ahead.

> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.3

I'm aware, and am referring to this tree. You can trivially rebase it
on top of hmm.git..

BTW, what were you planning to do with this git branch anyhow?

As we'd already agreed I will send the hmm patches to Linus on a clean
git branch so we can properly collaborate between the various involved
trees.

As a tree-runner I very much prefer to take patches directly from the
mailing list where everything is public. This is the standard kernel
workflow.

> But i have been working on more collection.

We haven't talked on process, but for me, please follow the standard
kernel development process and respond to patches on the list with
comments, ack/review them, etc. I may not have seen every patch, so
I'd appreciate it if you cc me on stuff that needs to be picked up,
thanks.

I am sorting out the changes you made off-list in your .git right now,
but this is very time consuming.. Please try to keep comments &
changes on list.

I don't want to take any thing into hmm.git that is not deemed ready -
so please feel free to continue to use your freedesktop git to
co-ordinate testing.

Thanks,
Jason

