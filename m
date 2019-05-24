Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B76C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E08F217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:18:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="a/c5aNCz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E08F217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9E5E6B0275; Fri, 24 May 2019 13:18:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4E286B0276; Fri, 24 May 2019 13:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A16546B0277; Fri, 24 May 2019 13:18:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82E806B0275
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:18:18 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id g203so9029439ywe.21
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:18:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7fjzoEk7VHLdIfi/lCjGQJd6xWD7AQcbop/UJoQp2cg=;
        b=Uk66p9nzP5VSoiEPDQPDdWBA6Ke8OyC6Ze5nXj+1EbBvzk2EgNL8v+GRCZCvFJymTk
         vmicFSbqo2HMc7Kqg8QaOLxUXps66Yuw8ZzJwsGwPKw/h3m8rvo0RVwaM3tYhopLAYEb
         7EN+VU5olU6ZIZL/NksyY4BajYf7MEc7TqRtyxQbNjTi5pwFMsoEDpjPY7bpoNRfy0QZ
         2739l6RLHc+eo+NBJq/vvFmak0Nh/s9GETzOrTirNZ1PhAr7LTK3ov7UNrcgpwiIkidD
         cVDCVapeYUby/430Mx7dURUtI6TrywCVAFvn7cf/boW0QVy7e9GfGZ/RGCnO5kTf2mLy
         FpFQ==
X-Gm-Message-State: APjAAAUYn3WNBE1qlKFU4Yn7vTyM2Q0RWX3zJCAcpFxmTfOHKilTXy42
	6i3GCGlIw6cm18hdq0WRhhq3qS3qi++pAJFEI4SdrJgZFEMXkpZCrGghBFlkSv9tAvadAFFONK4
	xI9mryN9kDGdYW+NBrsk75T2bgPFGmoc01ytt7cZBUxxgIT7mpL09blKk4fDefhrvOw==
X-Received: by 2002:a25:50c:: with SMTP id 12mr26025338ybf.462.1558718298247;
        Fri, 24 May 2019 10:18:18 -0700 (PDT)
X-Received: by 2002:a25:50c:: with SMTP id 12mr26025256ybf.462.1558718296850;
        Fri, 24 May 2019 10:18:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558718296; cv=none;
        d=google.com; s=arc-20160816;
        b=DprS+2TOECZCSJKbpK3U3vUJ5ktIgxt2NqwV2rkPlCwHA2mVd4jgu40EigsJI5Zzdd
         guwXmIp8gRN4qmsyKWa1KwrocOZO7DYZ/iMiiT+n/TrRjc+qDRo97z+xE6qSSAa9/3jc
         GO8BtF9zWfQbAS1v60IWIbteeS88e4G3dJfV02ALKl3ydK6j3fRHCnWN8jMUjlIzakOb
         PVjegWe/dgorXZkH9ZdBNZsxCp7Qg88yDSUpp97tblRoRsEA1S1bJhqANXSM5EMia5QI
         AC5neo5rrBblA+TJZP1PnOvGgrhz0ea2ba7fUjS+VLcAKYwBSrI+y4xg2mnVn0R3BAwk
         +2VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7fjzoEk7VHLdIfi/lCjGQJd6xWD7AQcbop/UJoQp2cg=;
        b=MgWYwLISHi5Cn89bg2+WtYi/IoiCJzOfzm/DyBcu4o+GJ0NxLIHTYB9DsUR5LtbF8h
         fZUB53MQR9OcXth34WBJuypQNlG9LlgasBs3QZs5R1kZZ+YK4WZA4Yc9v1LmZ7nlQzWp
         z7zhzdRNgk3+EDFhgdVSHvWyKba5s2f3yEjxRZXl7l/4mw2usIBHpxXehlr3GtBQmJQ1
         9LYX0ydzjrDFiXDJn9oX3XBPOXA45IMk9qcjKwzmCwIcBRPLyOAfaq0XYvNd/mSoS4f+
         qXyf3kibtpK0xctGQe8R9JgYOlx56Aj1p3go3MULFWSvlTzXYNBQEjABjeYZUAmmsapd
         F+AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="a/c5aNCz";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e185sor1608710ywa.78.2019.05.24.10.18.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 10:18:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="a/c5aNCz";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7fjzoEk7VHLdIfi/lCjGQJd6xWD7AQcbop/UJoQp2cg=;
        b=a/c5aNCzXO7PLBa6Ssaqn9PV4rrkGxnsM1xHZvBruNhViUf57ByhvKw3LDYheK9AVn
         7xJweo6a0bX6nCiUyOF7CyQkSOrwCnrRYJodZ7ZURffExgzgfwIZtij7VsdWYDlFMm4J
         CeQpx3k3MuKNFnJsl8HBdrM9eCTBqU2bjRihv6CICpP+ObFN3uYNQbM08yATD9rZYezo
         piWyxLCsiAi33onCQZ2vc9k53xG1v6VSYYloF6+HRn+tDtjZuHI2YULEcjbfU8sP7s9a
         LQDhUD/jirMOuLBVgP1pGxJ/WeylORNTxm5AX/+Ce1SLL+O7QVCsp/KxF6araNp75DBt
         JthQ==
X-Google-Smtp-Source: APXvYqzyCi24bS0zt4t5z9+kM3048deoltYoGq6J2shC7KVjEfqjZWrRksXqNV+c9NbCgXa7Mb/kKqN3XyJrvZZBLfc=
X-Received: by 2002:a81:7cc2:: with SMTP id x185mr11843465ywc.10.1558718295643;
 Fri, 24 May 2019 10:18:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190523174349.GA10939@cmpxchg.org> <20190523183713.GA14517@bombadil.infradead.org>
 <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
 <20190523190032.GA7873@bombadil.infradead.org> <20190523192117.GA5723@cmpxchg.org>
 <20190523194130.GA4598@bombadil.infradead.org> <20190523195933.GA6404@cmpxchg.org>
 <20190524161146.GC1075@bombadil.infradead.org> <20190524170642.GA20546@cmpxchg.org>
In-Reply-To: <20190524170642.GA20546@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 24 May 2019 10:18:04 -0700
Message-ID: <CALvZod5=N_hwGLFzCZY=DG0RfwzSt2sjJDcPZtCRy-NcBsLL+w@mail.gmail.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 10:06 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> On Fri, May 24, 2019 at 09:11:46AM -0700, Matthew Wilcox wrote:
> > On Thu, May 23, 2019 at 03:59:33PM -0400, Johannes Weiner wrote:
> > > My point is that we cannot have random drivers' internal data
> > > structures charge to and pin cgroups indefinitely just because they
> > > happen to do the modprobing or otherwise interact with the driver.
> > >
> > > It makes no sense in terms of performance or cgroup semantics.
> >
> > But according to Roman, you already have that problem with the page
> > cache.
> > https://lore.kernel.org/linux-mm/20190522222254.GA5700@castle/T/
> >
> > So this argument doesn't make sense to me.
>
> You haven't addressed the rest of the argument though: why every user
> of the xarray, and data structures based on it, should incur the
> performance cost of charging memory to a cgroup, even when we have no
> interest in tracking those allocations on behalf of a cgroup.
>
> Which brings me to repeating the semantics argument: it doesn't make
> sense to charge e.g. driver memory, which is arguably a shared system
> resource, to whoever cgroup happens to do the modprobe / ioctl etc.
>
> Anyway, this seems like a fairly serious regression, and it would make
> sense to find a self-contained, backportable fix instead of something
> that has subtle implications for every user of the xarray / ida code.

Adding to Johannes point, one concrete example of xarray we don't want
to charge is swapper_spaces. Swap is a system level resource. It does
not make any sense to charge the swap overhead to a job and also it
will have negative consequences like pinning zombies.

Shakeel

