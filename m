Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C087FC3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:55:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 672DA22CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:55:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="F8bCgYAm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 672DA22CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F6BD6B0007; Tue, 20 Aug 2019 07:55:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7C56B0008; Tue, 20 Aug 2019 07:55:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 896956B000A; Tue, 20 Aug 2019 07:55:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id 679FE6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:55:18 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1E6A4180AD805
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:55:18 +0000 (UTC)
X-FDA: 75842650716.15.pail36_11205d49ed909
X-HE-Tag: pail36_11205d49ed909
X-Filterd-Recvd-Size: 5361
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:55:17 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id u34so5624533qte.2
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:55:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cjWne9JJX/bamk/BsyOJB8Qocb+2jJnD/6EfxMqzNUc=;
        b=F8bCgYAmAkUxSVlSTscXxlQRELIsOQnZmrvm1sUjW95CUd0khTshKRxwCuLjyokKev
         BO8QDllptp/4vv0c5+22/EhhQN7BANX7GXbwhmoL4l4ncCnzuvcFIBhtQofbuqTX6nsg
         zwql74Buzj9teOKUbKfj5TE3uHNM/5fbApiO0JHQMUUYJ/unQvJimJ2vf/e7eXWfu4Qr
         e3qKOUbeDxtQCKEEnBFIKa+Y83F0ozkYPvP+sRDb4zW7tz+74GJgY/PNJGOy+FAsmX1f
         luk7Y3QQ++vwxmyoZVrHTbe9U0I/Qk1BqrxGPfTC0MFEGoh/lly24xPvz/0fT0h+OEJy
         qwWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=cjWne9JJX/bamk/BsyOJB8Qocb+2jJnD/6EfxMqzNUc=;
        b=EpuFNnusu+WxfTo1tvzPY1FZU4iEKiqOHmNLyD8wx2qXyL+b1PF94J1mc51yI1z4pd
         MrI3iOyzsdCRw5SFuMs6pP+PL/8EX+yRuiJoHb/1xfO6E6MmowpS0Nt0HWgb209Lf8cg
         m8pEiuHyH+r5o6Q0tU21f2KiOsSGM1tavVRmYFlRIeWSXP8jmtm1cOkIDjtja0bMuExS
         YE+UywhK0q+9kB0/qChbvMURl1+FJuOHBOkrioUuBfKdAQAi/rYblbiTuuXrWyS1q+d5
         tGv1q5Zg+c8INbImQFcyuGfMIcNjXBhN4wKbSPh26RiyDjUp+0eo6BgQkBe6tJgD7FJT
         CZoQ==
X-Gm-Message-State: APjAAAWr3o48A0Ay081NItZ19WIRYXgCanVeA/W7pP+/3W4oaJJUYMtS
	7aXN7iUSCr6U/uLZOSizXuE4tg==
X-Google-Smtp-Source: APXvYqz2loiM8+YcMWhCUXDCstClokgbXoeINv82DptJXTepeIjclfvYpo9S265xpxsrLBOY09rJbg==
X-Received: by 2002:a0c:d251:: with SMTP id o17mr14202195qvh.109.1566302116866;
        Tue, 20 Aug 2019 04:55:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f23sm8218362qkk.80.2019.08.20.04.55.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Aug 2019 04:55:16 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i02jL-0007t8-HZ; Tue, 20 Aug 2019 08:55:15 -0300
Date: Tue, 20 Aug 2019 08:55:15 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190820115515.GA29246@ziepe.ca>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190814101714.GA26273@quack2.suse.cz>
 <20190814180848.GB31490@iweiny-DESK2.sc.intel.com>
 <20190815130558.GF14313@quack2.suse.cz>
 <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <20190819123841.GC5058@ziepe.ca>
 <20190820011210.GP7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820011210.GP7777@dread.disaster.area>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 11:12:10AM +1000, Dave Chinner wrote:
> On Mon, Aug 19, 2019 at 09:38:41AM -0300, Jason Gunthorpe wrote:
> > On Mon, Aug 19, 2019 at 07:24:09PM +1000, Dave Chinner wrote:
> > 
> > > So that leaves just the normal close() syscall exit case, where the
> > > application has full control of the order in which resources are
> > > released. We've already established that we can block in this
> > > context.  Blocking in an interruptible state will allow fatal signal
> > > delivery to wake us, and then we fall into the
> > > fatal_signal_pending() case if we get a SIGKILL while blocking.
> > 
> > The major problem with RDMA is that it doesn't always wait on close() for the
> > MR holding the page pins to be destoyed. This is done to avoid a
> > deadlock of the form:
> > 
> >    uverbs_destroy_ufile_hw()
> >       mutex_lock()
> >        [..]
> >         mmput()
> >          exit_mmap()
> >           remove_vma()
> >            fput();
> >             file_operations->release()
> 
> I think this is wrong, and I'm pretty sure it's an example of why
> the final __fput() call is moved out of line.

Yes, I think so too, all I can say is this *used* to happen, as we
have special code avoiding it, which is the code that is messing up
Ira's lifetime model.

Ira, you could try unraveling the special locking, that solves your
lifetime issues?

Jason

