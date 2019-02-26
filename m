Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A861C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:13:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC6AF2146F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:13:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S/1urR1/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC6AF2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D36A8E0004; Tue, 26 Feb 2019 06:13:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574DF8E0001; Tue, 26 Feb 2019 06:13:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43C678E0004; Tue, 26 Feb 2019 06:13:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id E47E38E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:13:02 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id x15so665229wmc.1
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:13:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QHqS9FYiG1zBoxmbf0V7JRLtAFvidK6oH6Is4fIvoJ4=;
        b=AgMYh20raWZ4nX3KdSXqbBmfb/nzVFLCYnlijR8xnjQ2DxxxVbPeJ5my/M2ecY04wZ
         A7sTXKQmoEjFTdwFZAz4IbG9xfaD9Mdaj/SFuQ3s4d+h6kIuv7vo3wSVv7VcWl9Ga+wJ
         NGQtBUHfKkj6gdDn8H8KcxkDctFtFavtUAs2uyPKzyxakHB2yI+zmxhG9TIr1BKsJt/K
         jlZH99V4JDUtMU+0hHSaKXvYEI5Rt6hvvRnlb9ckPAPwrnRYrYKJyOr/SoJFx6xO1RJt
         JOwVeQuvp1c4SYJ4A1DkaHRv1Mipq7LFoAc6SmrquT9X6qAlsKTLgxfyzJpbX01ajiWQ
         dBIA==
X-Gm-Message-State: AHQUAuYOYH2EBzUArOnj/HfZTJKXqP0C1MB0tKOSaMn6mOKPFZITJ1IE
	+0SA0HsTQLhe2qSz0u95ZOVGnpSxPIUwOuk6xCzzaNNYopGD7ZkfYI+b2Wgc+yeE5SleVcPFoWC
	nHNOIciNoMECzDpxZ1BmlxlMNEnBMzi79X900+ZEwtmrZyJrjwdbZgzPSS9+2uA1zWN5sOSkXBV
	G8yJTWGm28KDbR6DSPGoXqxcBSIKN+NQmjF85g330iC0j5jjAYUlSzdq2JxZjCOoUoO0JLNNkZr
	t/BFjoia6k6JVtyf0QPVs2IhhpEop6wFJ0UXFCkAzcmMDbH2OipnKOcvCA/5zklG7dNPl9cMSby
	0QKoKY//mwPBTZpZIuFVGMk2Py3Qp6h58Lq/zo5ky+0dWjLeefLCio7QYWOUlntbucLhgThDn1R
	+
X-Received: by 2002:adf:e98c:: with SMTP id h12mr16928513wrm.302.1551179582497;
        Tue, 26 Feb 2019 03:13:02 -0800 (PST)
X-Received: by 2002:adf:e98c:: with SMTP id h12mr16928439wrm.302.1551179581555;
        Tue, 26 Feb 2019 03:13:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551179581; cv=none;
        d=google.com; s=arc-20160816;
        b=ymfKPuni2kcItSLbVfaJRKKWHwQ2hm5TJ/CFj4ktrAAkXv0bAeIVoLog1fSo0jUtVf
         Y5kpIlqAOBMVzpLSXKsnNhN9MpwdeKRRHGNJ7JawDHwGkrNKejZfm8jKyp2WLT1XUr3v
         d0Ti6HUaL4EPkdpawD/WjDDyfpCuocFOgBFJ9Hjn0ZT+qRwsiXmrr5ctT7Lp7amNRIGx
         PDUU6ztXg3ZPSLlleeFEn9pGgTIMYo9KdIq2tnzMMVXW7dUsu8FKTlAHx8gXf6zyiX9J
         jJj97ORCN06v6OkjOEIQUehp2eue082klE5BlXSO0jFOz2D6oM7SKRNrVp7Ru2vHlnWY
         1V9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QHqS9FYiG1zBoxmbf0V7JRLtAFvidK6oH6Is4fIvoJ4=;
        b=i6+I1M5hK1LcuRgFf8StXOzS5h0WuZtG0JPIAy/s77A0nYkqlcxZyxI9xUiGivDem7
         sUMaLxAbry3sJCFSvMVn4qr1DXx5lsJJ3RR7tNxvY1t1SO/b9rH5gcaqa7YhMtddU9qu
         gvCGkyMPZb14AosmFAMLla5TGTl+fnW67ANKErmVmrBIbseeHMJkB1XRzmxbbkf17MCi
         k/dMSA9wCtIildbykPg+uoGBmWYjjtaKrasz/GQPqbbtyIift5nh9eMuSF14KW78JvU9
         vwtEwI/IVz8fPxjCMC2XNFdgNbqJJRBFTpDNWAV4LfscJVYVsRDpq+Y9JtQzHLL+pjsQ
         othg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S/1urR1/";
       spf=pass (google.com: domain of tom.leiming@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=tom.leiming@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor7049048wmk.14.2019.02.26.03.13.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 03:13:01 -0800 (PST)
Received-SPF: pass (google.com: domain of tom.leiming@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S/1urR1/";
       spf=pass (google.com: domain of tom.leiming@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=tom.leiming@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QHqS9FYiG1zBoxmbf0V7JRLtAFvidK6oH6Is4fIvoJ4=;
        b=S/1urR1/rCTfMI1kbuJXJVXFlPl3G6THigx/0Jl7udoDmkpi0LLp4elqtSaij71S0w
         DM/045jwfOAxNjQJFtqBG8+M6eo45azAxkNwkFpJtBETXpO160FfKt0FIZJrVUQln3fm
         NcCR/KpQHaP+QM9rZHjN5akaMlmm7nBhlvEwwY/8SExGZsAtR7BCpUuRfyWPUYMTcyUC
         bUf20RQw5vhu2QBReLIhpMWz6gnfCgOIIYuYP6R8IYIGEYrT8NKX69I5JndO4l6RZuLi
         FVgwenrihVyYPnNSodd0OBe7qFYgZJefpalW3heqhStIGDL04vhYyH8Cek4NrTuMlTwH
         +h+A==
X-Google-Smtp-Source: AHgI3IbJHz73B55lSuZB2tgChvWyG+f3SNNJuU9R8d5KDwOBP8Iye0XxT6ZxlngQszFhVsJ56xW2KpcEMqMJWS1vYZk=
X-Received: by 2002:a1c:eb1a:: with SMTP id j26mr2173623wmh.43.1551179581180;
 Tue, 26 Feb 2019 03:13:01 -0800 (PST)
MIME-Version: 1.0
References: <20190225040904.5557-1-ming.lei@redhat.com> <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz> <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p> <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org> <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p> <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
In-Reply-To: <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
From: Ming Lei <tom.leiming@gmail.com>
Date: Tue, 26 Feb 2019 19:12:49 +0800
Message-ID: <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, 
	"open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, 
	Vitaly Kuznetsov <vkuznets@redhat.com>, Dave Chinner <dchinner@redhat.com>, 
	Christoph Hellwig <hch@lst.de>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>, 
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-block <linux-block@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 6:07 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/26/19 10:33 AM, Ming Lei wrote:
> > On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> >> On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> >>> On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> >>>>> Or what is the exact size of sub-page IO in xfs most of time? For
> >>>>
> >>>> Determined by mkfs parameters. Any power of 2 between 512 bytes and
> >>>> 64kB needs to be supported. e.g:
> >>>>
> >>>> # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> >>>>
> >>>> will have metadata that is sector sized (512 bytes), filesystem
> >>>> block sized (1k), directory block sized (8k) and inode cluster sized
> >>>> (32k), and will use all of them in large quantities.
> >>>
> >>> If XFS is going to use each of these in large quantities, then it doesn't
> >>> seem unreasonable for XFS to create a slab for each type of metadata?
> >>
> >>
> >> Well, that is the question, isn't it? How many other filesystems
> >> will want to make similar "don't use entire pages just for 4k of
> >> metadata" optimisations as 64k page size machines become more
> >> common? There are others that have the same "use slab for sector
> >> aligned IO" which will fall foul of the same problem that has been
> >> reported for XFS....
> >>
> >> If nobody else cares/wants it, then it can be XFS only. But it's
> >> only fair we address the "will it be useful to others" question
> >> first.....
> >
> > This kind of slab cache should have been global, just like interface of
> > kmalloc(size).
> >
> > However, the alignment requirement depends on block device's block size,
> > then it becomes hard to implement as genera interface, for example:
> >
> >       block size: 512, 1024, 2048, 4096
> >       slab size: 512*N, 0 < N < PAGE_SIZE/512
> >
> > For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> > needs to create 127*4 slabs.
> >
>
> Where does the '*4' multiplier come from?

The buffer needs to be device block size aligned for dio, and now the block
size can be 512, 1024, 2048 and 4096.

Thanks,
Ming Lei

