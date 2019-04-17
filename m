Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E370C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A4F721850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:54:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="nE8Uv15i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A4F721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF6EF6B0006; Wed, 17 Apr 2019 17:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA6EE6B0007; Wed, 17 Apr 2019 17:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96F296B0008; Wed, 17 Apr 2019 17:54:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC596B0006
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:54:48 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id j5so3686oif.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:54:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0gzMaLLaGdWl3hSChkCJQp0aKInJbM+8lmL2ZmU73jg=;
        b=daBZes+qQALYQkiHlzrGcuNXfrYTWdWnd6L8Mmhv7JTnAeXFI7XFW3kq7TQRjd+5C+
         bdHTd9OfK7hVj+XbuYUJMkHVMRDj3lGrNsxkTXH5vK/NY18wqRA/6hXsAPsrS+ZeUC/S
         cTRw21kAv+WJwLYxlra7HDkFaCQkvmPylYH1GrdRhmfAq7WRGEevG6eaEXKxwoLyraYY
         wqGYFe+kNT3k5iWeslzcYhwpm9xJ2NvgWFm9ybT9fSvF1G+jUHsm2KP1C5s7zbrkfv6T
         EpHO6zPpNxn+Ay2jSFFSwhDtBpbIesRy11gWdyMXtJt7JS20iniO2sZO2sfQrZc178Ep
         rblg==
X-Gm-Message-State: APjAAAWz2JGTeDzOvAQLCQWwxQczl2Y4RPmsv59MEG/BuSZsHlZIq79P
	t2xfZYwpCH5kdgafymKdOBVFmGflObfKtvPD0jqs07yIbLgBalswFX9+GVhs+d+bFbCdPoTpaO3
	Zyo8GY3E8xpE0OuyAvL4xn9tdBJO/WbZh5L5ra3Yp6VGByEc+HBdwwe0zFju4oE9uIg==
X-Received: by 2002:aca:b604:: with SMTP id g4mr508808oif.155.1555538088181;
        Wed, 17 Apr 2019 14:54:48 -0700 (PDT)
X-Received: by 2002:aca:b604:: with SMTP id g4mr508786oif.155.1555538087596;
        Wed, 17 Apr 2019 14:54:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538087; cv=none;
        d=google.com; s=arc-20160816;
        b=f/ed4BH9jbXUBPJcdgChuT3z6MzsURygZyZ6qg5K2/YvUIl+a738/Z9QzCWQy/dS7a
         kN73hinY+a6BkuO69gU0mcPEdVG/vMUo2I4fEFD1iWgOzFFL3+yVZ+py2nuhmf8yOVLt
         y1qRT7Qsu+i8g5oStN+je9tijSb82+zL3Ec+Cn6bRoA3Ow3yLl7QXaw6EUGBVUYsS/6/
         CrsWLCOw5F/l3FNeiV9pgKxClsE234LymDCpaGxsiXz7lx4rsZIn+8metL9L9td22ndR
         bPQyRqMoqcHcu0e145qB5MjKi8N9Vx03FZtP9V6g/2meE411TySpQpazmFoghjZ9CWGE
         NvCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0gzMaLLaGdWl3hSChkCJQp0aKInJbM+8lmL2ZmU73jg=;
        b=gTfdb0k2dL/JPZ73KJnVTXhmwj3T6YYRLzS6rJHPciweXPpYIbEgRAGBm/P8j2vftQ
         1rEgd+G9le1+y9yeOZ+Gg/AeO9PyA9fK7FV65IecmnVhJ3GUeswIooR+tegjvqns6m0z
         Y1U3EJrynIOeB/Cy3F6x7AgRJ7Ioy/6uKjx72dqYUuextxGouLv2XVYL1/u6EKoimQ5v
         FBT28fIuULEvRqK0HW+T66PhzLLCGjtsCQ79hj3ycB7aDkkNSvXTXzd89jtoo0+eJt2y
         S2n0+oo5GILC0Ne0enWlFb0sJxGwEmlqBgpbKHZMMta/wQIpV3gtq4JMcpIp8CYcC8MY
         999w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=nE8Uv15i;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor20156oib.165.2019.04.17.14.54.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 14:54:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=nE8Uv15i;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0gzMaLLaGdWl3hSChkCJQp0aKInJbM+8lmL2ZmU73jg=;
        b=nE8Uv15i9sJ9T2QCxWTOE/iQD1bpVlwdwn8GzP1/6K5ajHJB2ThscCe1BBipf81sRG
         7Ki4ZanzmXpROhRumbSMNtBcN0vgTQuSWTzTYdQPEoZGpjwEVEhJ59WUlSTFALaQX/w3
         Ao2ANSK+tabdBGgLtc8Px76vWply/4r5eKmyAhe8o5f2HGs6ABsSLSDvV9HFg1Yuv+XG
         bB6bFe5tJ3nBzUWG3kffvZ5VncmP81eRT0m7NHbSaZaiAzOell6TbvdTtFLkBs9XmX/2
         Zvzd5gGqyvR+yJ3vNotGqM57OTMZwvzIHihHOHg5eo1Kr57GoOghV8lV5p12oyDmYs7D
         VfqA==
X-Google-Smtp-Source: APXvYqyqbZkKrQu9PG9OfbWt5ClCfO+XAk2lSd/W1ElRySi/w9Gfz2hltItUkNjyrAWhso6NLBnigyhcnGeWvHliB84=
X-Received: by 2002:aca:d513:: with SMTP id m19mr548506oig.73.1555538087242;
 Wed, 17 Apr 2019 14:54:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190411210834.4105-1-jglisse@redhat.com> <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel> <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
In-Reply-To: <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Apr 2019 14:54:36 -0700
Message-ID: <CAPcyv4hgs8fC+CeLTwqbjVqFE_HFiV-UQBankMBp5NmCniuBFA@mail.gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, 
	Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Thumshirn <jthumshirn@suse.de>, 
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Steve French <sfrench@samba.org>, 
	linux-cifs@vger.kernel.org, Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org, 
	Eric Van Hensbergen <ericvh@gmail.com>, Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dominique Martinet <asmadeus@codewreck.org>, v9fs-developer@lists.sourceforge.net, 
	Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, 
	=?UTF-8?Q?Ernesto_A=2E_Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 12:28 PM Boaz Harrosh <boaz@plexistor.com> wrote:
>
> On 16/04/19 22:12, Dan Williams wrote:
> > On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> > <kent.overstreet@gmail.com> wrote:
> <>
> > This all reminds of the failed attempt to teach the block layer to
> > operate without pages:
> >
> > https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk3.amr.corp.intel.com/
> >
>
> Exactly why I want to make sure it is just a [pointer | flag] and not any kind of pfn
> type. Let us please not go there again?
>
> >>
> >> Question though - why do we need a flag for whether a page is a GUP page or not?
> >> Couldn't the needed information just be determined by what range the pfn is not
> >> (i.e. whether or not it has a struct page associated with it)?
> >
> > That amounts to a pfn_valid() check which is a bit heavier than if we
> > can store a flag in the bv_pfn entry directly.
> >
> > I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> > an 'unsigned long'.
> >
>
> No, please please not. This is not a pfn and not a pfn_t. It is a page-ptr
> and a flag that says where/how to put_page it. IE I did a GUP on this page
> please do a PUP on this page instead of regular put_page. So no where do I mean
> pfn or pfn_t in this code. Then why?

If it's not a pfn then it shouldn't be an unsigned long named "bv_pfn".

