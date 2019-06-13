Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3AA4C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:14:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CEF3208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:14:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="pyVy5aBf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CEF3208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F34C06B000D; Wed, 12 Jun 2019 21:14:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE5046B000E; Wed, 12 Jun 2019 21:14:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAD5C6B0010; Wed, 12 Jun 2019 21:14:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B22386B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:14:58 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id d13so8541010oth.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:14:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RcKUTNC1/Yaa+Z7YVTaDTsC+idf0Auxj860bjLfby9Y=;
        b=dVqZgd4gLktjldOUm5uurpjJbGjjeL6HvFOq7eVOBomKAeRTvJamADFiiosOKQRs0I
         v2/ypqAypzdIrgfYt6cW5jv1kSnp2+Wv5D9Un3OEFKXCqYsUGYmd9QOsmeLD8pZO0erw
         mqrs99fF9icithe9eLN4RNXuQ8jHQ8damvXcKXQKtgYrvHa8K3MnionpkgZOpbyQrYhb
         RhhSzGMvgLuNpk4kWnfpCrYYzJrA7gttfB6FnWE/nMaLDvsTJo/Nk0oR8ejXnck7REXK
         xMJDctQGyXXij/xVQdLwUeBmOaJPEQz+eg+KZEdSgxsJeOBk054zKZxkfspLKawTNbrX
         0nrg==
X-Gm-Message-State: APjAAAXD0l2ZgxFVUuPVT0ni7Iymny4vujb/gZlh7IaAuK9x03qOIvo3
	/Bz9x+qL7zbiz/qtx6ybI7D3BJmtRhBpvnuihgII9oSbD6bICofA1At5xTyi34d8HEBOb71OATc
	gAFLh/zmiom/ZM6JG3AntrVuc8kKCIud5WuGwhb8u2zVkidTtbqb1G2yfi/wMomDhuQ==
X-Received: by 2002:a9d:6a19:: with SMTP id g25mr38104905otn.77.1560388498280;
        Wed, 12 Jun 2019 18:14:58 -0700 (PDT)
X-Received: by 2002:a9d:6a19:: with SMTP id g25mr38104876otn.77.1560388497555;
        Wed, 12 Jun 2019 18:14:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560388497; cv=none;
        d=google.com; s=arc-20160816;
        b=QGoCCF5tLF56br+DMqfDHUHGfQ9eFt7ckQBVYo5+e1rTKGb9yyVlyO4QclODSV2YGS
         Lt6P4iBtw0JZG8nPkFPtd3SHLaSlhNVv8JkBjWkSTAXJDp4T/8g54QWRjz7E8iymez5L
         bf2764UftsIU8+wbLrjnk0az8v4fsmM7cEF4YybLn1Yp6s2xE3Q0iPlkn9iPnz+MrcVe
         KCvvvsIgaTFX6b4oASiwRjn5c2MYvChGcW6DkESaDtqNaD/2nXtjjOuEKYVkaxwK5ffT
         G/+lvlD4zhWQ2E3cmBPNd/13+gdb2zIEgGgjuA9/IGBk85XLNJOz8eoB64MJqPxNBft6
         7n3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RcKUTNC1/Yaa+Z7YVTaDTsC+idf0Auxj860bjLfby9Y=;
        b=A0QgVGqaZEGdz/MmUN/2dYg3zJK+KLEeMuIujNF9/uXqI6germUiyW3/WImjXREoC4
         kck4ZhYKnBmdDlEodhd1pI9TkMrJs7/Xa4Tn0BjyE9+Tsjr+WKy6y11/lIcbuxx6m2r5
         wzvW7n2bq8qg8v1Q2CxGttC45TMOTvuyiXGaWym68f97r0gT2HkyvE2W4XTu2n6kUMdp
         eMwpZ52QxClVfvkyDnthPAaBwe7Fuu9JBO0i6tLbZgbd4kogTxLzTcbe2h5bZAIm81a1
         Iuf2t9Crhi/LV3FPmfUlz853AvYFRtq2K1L7eO9EJ6lIQQF7Myld613W8O8mk6AXVGY9
         zGKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pyVy5aBf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c126sor753466oif.122.2019.06.12.18.14.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 18:14:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pyVy5aBf;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RcKUTNC1/Yaa+Z7YVTaDTsC+idf0Auxj860bjLfby9Y=;
        b=pyVy5aBfnvmLd4LmS99NC7v2hHH+z4UZs9t88ZWrifMnyNQ1ntVXoql6oB68VhzVo1
         F8hclQ0Wyg9MsOlwr7j9F9a5FwakzRc0cX63T9oeseLCkWGBIj3OBaI1LL2HQs2XiGNX
         ETH5Cv/Dp91sVJ4t+YsWm75tFBfI5P44fYs8oiCUlHe8OHYW0zmCh+Jz3mI3juP3eG0d
         bwg8PkQXV/rh9Ruhio4gTK3UfuitZunT8jlU1uJv5ynSJJDHBTJWHqmmDp1yyxN5HdDN
         3nC3in/UilzgUI6FwH3DI0lKZs/DXkSb6pM0DXEBpGmyHzzfZCjAONw9LI5SpclpGpd3
         Jyhw==
X-Google-Smtp-Source: APXvYqykCVdxD0fjMiZ7EZWZAtb82hdqz1hJdJILcfFTKlDzRoucvcWvFMaxGMog6wRYrJg2D1GBjocrrJhQVeNNqcs=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr1431023oii.0.1560388497122;
 Wed, 12 Jun 2019 18:14:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz> <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com> <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca> <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca> <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
 <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com> <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 18:14:46 -0700
Message-ID: <CAPcyv4jf19CJbtXTp=ag7Ns=ZQtqeQd3C0XhV9FcFCwd9JCNtQ@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, "Theodore Ts'o" <tytso@mit.edu>, 
	Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 4:32 PM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Wed, Jun 12, 2019 at 03:54:19PM -0700, Dan Williams wrote:
> > On Wed, Jun 12, 2019 at 3:12 PM Ira Weiny <ira.weiny@intel.com> wrote:
> > >
> > > On Wed, Jun 12, 2019 at 04:14:21PM -0300, Jason Gunthorpe wrote:
> > > > On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> > > > > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > > > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > > > > >
> > > > > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > > > > little HW can actually implement it, having the alternative still
> > > > > > > > > require HW support doesn't seem like progress.
> > > > > > > > >
> > > > > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > > > > on fire, I need to unplug it).
> > > > > > > >
> > > > > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > > > > with such an "invalidate".
> > > > > > >
> > > > > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > > > > everything that's going on... And I wanted similar behavior here.
> > > > > >
> > > > > > It aborts *everything* connected to that file descriptor. Destroying
> > > > > > everything avoids creating inconsistencies that destroying a subset
> > > > > > would create.
> > > > > >
> > > > > > What has been talked about for lease break is not destroying anything
> > > > > > but very selectively saying that one memory region linked to the GUP
> > > > > > is no longer functional.
> > > > >
> > > > > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > > > > and closes the file with existing pins (and thus layout lease) we would
> > > > > force it to abort everything. Yes, it is disruptive but then the app didn't
> > > > > obey the rule that it has to maintain file lease while holding pins. Thus
> > > > > such situation should never happen unless the app is malicious / buggy.
> > > >
> > > > We do have the infrastructure to completely revoke the entire
> > > > *content* of a FD (this is called device disassociate). It is
> > > > basically close without the app doing close. But again it only works
> > > > with some drivers. However, this is more likely something a driver
> > > > could support without a HW change though.
> > > >
> > > > It is quite destructive as it forcibly kills everything RDMA related
> > > > the process(es) are doing, but it is less violent than SIGKILL, and
> > > > there is perhaps a way for the app to recover from this, if it is
> > > > coded for it.
> > >
> > > I don't think many are...  I think most would effectively be "killed" if this
> > > happened to them.
> > >
> > > >
> > > > My preference would be to avoid this scenario, but if it is really
> > > > necessary, we could probably build it with some work.
> > > >
> > > > The only case we use it today is forced HW hot unplug, so it is rarely
> > > > used and only for an 'emergency' like use case.
> > >
> > > I'd really like to avoid this as well.  I think it will be very confusing for
> > > RDMA apps to have their context suddenly be invalid.  I think if we have a way
> > > for admins to ID who is pinning a file the admin can take more appropriate
> > > action on those processes.   Up to and including killing the process.
> >
> > Can RDMA context invalidation, "device disassociate", be inflicted on
> > a process from the outside? Identifying the pid of a pin holder only
> > leaves SIGKILL of the entire process as the remediation for revoking a
> > pin, and I assume admins would use the finer grained invalidation
> > where it was available.
>
> No not in the way you are describing it.  As Jason said you can hotplug the
> device which is "from the outside" but this would affect all users of that
> device.
>
> Effectively, we would need a way for an admin to close a specific file
> descriptor (or set of fds) which point to that file.  AFAIK there is no way to
> do that at all, is there?

Even if there were that gets back to my other question, does RDMA
teardown happen at close(fd), or at final fput() of the 'struct file'?
I.e. does it also need munmap() to get the vma to drop its reference?
Perhaps a pointer to the relevant code would help me wrap my head
around this mechanism.

