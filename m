Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84D85C282C5
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 17:57:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BB6B217D4
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 17:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jxdzYmAS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB6B217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B6AE8E0038; Wed, 23 Jan 2019 12:57:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 664738E001A; Wed, 23 Jan 2019 12:57:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 553508E0038; Wed, 23 Jan 2019 12:57:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 267378E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:57:23 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id b8so1502461ywb.17
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:57:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=znQqA7mNprkXHZ2TRenByp8okFQwW7BAurjbNn0fM9Q=;
        b=YGqxsAwxXCSQ5ISojti8wZap+nk/raznrt2eZQcOGfP8vPqtYBkUqNPWmm+dEfCGWz
         MgNqDcwJQdO6hDsIhTwC4O3/FfpwtaIoP/ljxsOWxluEsYVL+1atS9hZ3nfa5aoRhBlf
         nnXDvFJJJwtlELNoiYjQHU0WWq9jFu59LxOlsjQIS7clKRCNr5xTs0XJh6AA+sFZhllr
         4Q9SwlpzMZlucr4YvfBbRmhBL71B4rdWzJkOiGjPCJPlFP22zgEZXtNxXKmWfz0YgSrS
         giVpIAzbnB5HOOtqsh54f3EMZEwwFxo+5c+mYuRg+xBPnmLW1d7EqozDP0IuCBxh6EnQ
         0LbQ==
X-Gm-Message-State: AJcUukdA2Sm2cBemyi4in+CInN1HptUpqtbBC9CTN+H+y/2RfrUFZg2F
	60L/Y9+3TQf0WNSe3/MzsPM3HYCSBbccThqMgRDsv2xKmLEtKMriDGdE2vNUaFjsIfQfz9WVMZ7
	/1M3amnh8wAZkYxwt4BAlAkdInB5ofWKwxhj+KKoCzyk6Fd3Rn3mA7E4wucaKjlcA5O+zYnP5bV
	3snT018aEj6OTvaq1SXEc8OHvbm5W51IJWzY3BsXI6YqGlzOj2Jc5SOsVync8quTSq6Vc44Nerq
	+5Zw0j7U+C8tTeifAOEpDx3Brkds8nXdH2S5kRgy27uEBVTkn2oEo1XkZZsvn0y0p5r2m5GofDZ
	B7yt/6GwhFYJZ8ru7235fJpDuKktmp7ddST3MsE45znEnhIRuJrwHVq4eoYCCcTNm+p54XUTHPz
	7
X-Received: by 2002:a25:39c7:: with SMTP id g190mr2949610yba.447.1548266242789;
        Wed, 23 Jan 2019 09:57:22 -0800 (PST)
X-Received: by 2002:a25:39c7:: with SMTP id g190mr2949581yba.447.1548266242108;
        Wed, 23 Jan 2019 09:57:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548266242; cv=none;
        d=google.com; s=arc-20160816;
        b=LDj3tLzt2ylgZA4UgQgrTNIr3fWp2+Tq5NePm+iYi40Uke5rg4ubfpPud6COjQ86/y
         Er68OaOOpWGdHSe7Zv5KJqCvbosS8iPFuxsL1k31qL1E3Xe4DgrHDtBjY9RIYbHq/KzC
         ziPNugn3zGCUtKHfngV7hvTzVLxZ9ElqtkHs3kCXvwhqskG3MlXU1wMsSwdmchfevITH
         LG4w0gZPs1N8BExvTO7Zkte0cNDFzWxW8Dg4D6Jx8U4PQWf3Flg6d6647nAmgSyVyiXx
         q2kvc3EvD5UH/ZSFL7umnqJIH1H9yTDubWrOcJ/72Y8m+HzJKA4j85QAQcW8ewdr3Am/
         zR+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=znQqA7mNprkXHZ2TRenByp8okFQwW7BAurjbNn0fM9Q=;
        b=ySE5cbNiOC0n1J3gNlx5xYwKYqgP/MMuWm8fT5/rlUEqxmJflElL7LHGZaWe8amxAc
         LswVDSaj+hbxgcfVJKhZecdfQivDrWXIYhL91kWk3IQeYs2Z2Gs9ckOmXdZq0NfWNEu4
         J36l60ROPQIboPE2KmkCNPUfhTxz9GXzWMKfWp6LCZWq7Bvtd73R5yJfSBNdFPnC1s3l
         lBUUoO72+OvzlHCvC3acwj4vPTaN2f38Ce0B6lWL8n71GLaco4rPWOecAtH553rqCWBp
         ULNAvSFVO+KmByHMS/xXv8FA2+e60Hl0hT7n7o5zrK8Wb9sq2exUs5iNRtL8YkwUjVOx
         AUmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jxdzYmAS;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19sor3405508ywd.166.2019.01.23.09.57.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 09:57:22 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jxdzYmAS;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=znQqA7mNprkXHZ2TRenByp8okFQwW7BAurjbNn0fM9Q=;
        b=jxdzYmAS7ubIO9o41WdqY5xemN/D+59e66eOMwuBw+y1E49yj70bQnGqBXb20svttp
         4fzNMaV0Fltj8aY+yUXLdPVTBDM+AP+qPud+Zg9pKVeL7Z5z+rtLLMIEPToTQahiDEwk
         otpr8luIZ7hUrNj91Py//2ZNMw6j7ln1HDI53zfyJ1R9zeylSCSYFSFX5kUODKzi3k0f
         ItlovayeiMMuYWTmo+QiEsoTj0Qfdv1sPurpEJ1X7WgrpmQoGo8ISdRnxiohVZwODe+K
         QA1nIX0BKllaL2yB8ANoL4LwLuW4/CSBS4B6lD7Gm+0Ht72ozs32OrNJrlgZBHkkDHzF
         Htow==
X-Google-Smtp-Source: ALg8bN6VZ2nAmLEdz6Xzm4ATBXIcC0UgAavQg2EahaPQTEvP4o5XnjIkCej61qC4WXFp0p/0K9ufWaWbBgnbu+M4r7s=
X-Received: by 2002:a81:34d3:: with SMTP id b202mr3042722ywa.241.1548266241657;
 Wed, 23 Jan 2019 09:57:21 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
 <20190123145434.GK13149@quack2.suse.cz>
In-Reply-To: <20190123145434.GK13149@quack2.suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 23 Jan 2019 19:57:10 +0200
Message-ID:
 <CAOQ4uxivipnXihRud_5cUmjeOj000MwH5+oVDWv_2kwGCsamDA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123175710.jQeoSpSxg1kACD8c6-Lv8SYzKnfyrwVzMCvgvozHTss@z>

On Wed, Jan 23, 2019 at 4:54 PM Jan Kara <jack@suse.cz> wrote:
...
> >
> > At first glance, this requires dropping the assumption that a for an
> > uptodate clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
> > Is there really such an assumption in common vfs/mm code?  and what will
> > it take to drop it?
>
> There definitely is such assumption. Take for example page reclaim as one
> such place that will be non-trivial to deal with. You need to remove the
> page from page cache of all inodes that contain it without having any file
> context whatsoever. So you will need to create some way for this page->page
> caches mapping to happen. Jerome in his talk at LSF/MM last year [1] actually
> nicely summarized what it would take to get rid of page->mapping
> dereferences. He even had some preliminary patches. To sum it up, it's a
> lot of intrusive work but in principle it is possible.
>
> [1] https://lwn.net/Articles/752564/
>

That would be real nice if that work makes progress.
However, for the sake of discussion, for the narrow case of overlayfs page
sharing, if page->mapping is the overlay mapping, then it already has
references to the underlying inode/mapping and overlayfs mapping ops
can do the right thing for reclaim and migrate.

So the fact that there is a lot of code referencing page->mapping (I know that)
doesn't really answer my question of how hard it is to drop the assumption
that vmf->vma->vm_file->f_inode == page->mapping->host for read protected
uptodate pages from common code.
Because if overlayfs (or any other arbitrator) will make sure that dirty pages
and non uptodate pages abide by existing page->mapping semantics, then
block layer code (for example) can still safely dereference page->mapping.

In any case, I'd really love to see the first part of Jerome's work merged, with
mapping propagated to all common helpers, even if the fs-specific patches
and KSM patches will take longer to land.

Thanks,
Amir.

