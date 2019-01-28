Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08E64C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 23:31:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A95E02175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 23:31:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="eQE95d5R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A95E02175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42ABD8E0003; Mon, 28 Jan 2019 18:31:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC468E0001; Mon, 28 Jan 2019 18:31:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EFB88E0003; Mon, 28 Jan 2019 18:31:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E41E48E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 18:31:44 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so12887589pls.21
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:31:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2GP9OAGVV8ccDNyAepGVTM9EYcpaJQelC09NNR5eJcQ=;
        b=AYqE+v8RyCfTOxKZUXdhQxe7QxXCTk990QjM2ro9VWca33mYJ0kjsusdaz5Ji52BK5
         kpq3TILwldaLU4GZLCOxQhZ9mqoP5DV3NU/RnRjJaRyW/dFC2q5xDfxQ/owg7TCY9hwn
         MTgb911Xqh7Re9DYodOniO3AVcAgJnJ/5t5T38fztjtNxk4QlCc7Bw5Y4/FtYBZfMgNr
         1bzwOupJQdVUh+WhJlGPR5b/2nG4cdw/y9ar+nxmExcZv6FfmYmm41HTISUFj693mhcR
         x5FFKORcbJ9XkjxerKZS8Jwsgsdy2zpnzZdkkSyb8H5SE6PFjWqbEu9FLsv6l8lLY0K/
         ZcXA==
X-Gm-Message-State: AJcUukeRTVAFNl/EX/gTncqZ8J4t77jBtygplHkOj/UsFHYNzFRpzZfD
	XF9F6IkVdVghHsrg5vZ90tYKqjKdNr9QAnSpibCE++CX1YogNMuSEzocGHw2Wwx8ZZenBj/p/Rj
	4ZQSepSQrwf28t/j/POz9wNGdEDe1xiiwefDiraTExihQNXVEyo68SCX39ws7rqHQI0eFSHfNtS
	LmA2pa8B+NF4CsiaJ3WD6kGb4yUFkoLLxFhGrkUB+j0gxrqbdpLBa1nKnqSIVl3vJbRxLs3PEGf
	owGDaUl68G/9ZLRUJt5hPR42FJpfpxfbSpSKirL7BR5jBhMVmy5gtLVrpzo55z8pcFAcwUE5tRN
	BVmFnssY4liFtZAQ4cIFjlCWHuGyKb6EJpITFlEyNl6lg9Nz//mAtgI0VNMzRZOqCtehiYsZMIM
	J
X-Received: by 2002:a62:5884:: with SMTP id m126mr23720191pfb.177.1548718304587;
        Mon, 28 Jan 2019 15:31:44 -0800 (PST)
X-Received: by 2002:a62:5884:: with SMTP id m126mr23720154pfb.177.1548718303779;
        Mon, 28 Jan 2019 15:31:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548718303; cv=none;
        d=google.com; s=arc-20160816;
        b=SLY+Md9X2OE8i6nEi3VCZJcuL9q/UozoqREWtFQA6JzjVLWU7osP3eR2jYri2vWOzM
         gWB9gg7s7+nc1RAmD/w2Cl+A8FpxhKs5P3Ouu4AyztWYvyTA7JyYdy3O3Wr4DDPVv8BA
         dXQ4PcJgk+vukYWTCc/60REJH1hKWN92xbtA4uo3mz7k6VsHUTePsxvWsdJza9B2+bSo
         kTZrNDb5QIAEkYF2vFefFmxoBJKW95+t6yU60TTty4+4iqncvcGbnI7BP5Vz3gp3ARz8
         Aud5DVlGSgNKhhv/81bG6pduWfHiNoKnFYSyt3tEZ4kF37D/NhXPTKfkFqVJtpOOg/oZ
         G6hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2GP9OAGVV8ccDNyAepGVTM9EYcpaJQelC09NNR5eJcQ=;
        b=l2266LNSxYkYzfxQZlvWSJYbLqKq9h7PVqeGgpmWY9mBUPl9NPWmRzpWTGjhXMMLnJ
         oYd2HgminRwriChMkcSfA0vSgJPi0PgPFsfYsnS0a5x1QUkMbQKlcC9cKoIjj+TwDKBf
         T+TDAdCOqn3iLfjOrm0EyWcozG7pgKySXIGWMMTIVQ/ud7lFxAFmP8vEUV4U9HL0Mmy0
         dHNIpzkt/Bygsj/duCP+D7y9L6pXKbFysFNrIN04SCaAGEbRr2QvqhuOfWmv6P5cMr/H
         R1+BjEx7Sk8fxDla/wgbJ9vLx8Qwbqg6ncfc16ZIzObrtAgIN/Wy5jfQamWwUyBRHL7r
         A6og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eQE95d5R;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e39sor4994156plb.21.2019.01.28.15.31.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 15:31:43 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eQE95d5R;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2GP9OAGVV8ccDNyAepGVTM9EYcpaJQelC09NNR5eJcQ=;
        b=eQE95d5RELF3bKEHIk+lmha6kOQ0S60/ds6r0KKG0IwlLLwBdX92krhKyQwNvZGR22
         JroDhbp8CSVIm5xkiK3cfpE/DG3JQmrX0OBxkC/l7Ha9zqU4VgAdpR7yC433xEiPmHiG
         NwflLaEzl7cZfLwEoDYOMmbqgy4neW6OGhz6qCJwl7OySlTA5FhLaU4VQjcE/b86lRMB
         FaBz4U1Dm3aT82LHJFl8zhg/KPDPlrpyQrsWoAlNSlFme2Y6//8VXjZfZJxAYJZda7LJ
         AnxR/8YSjHI3gFI7Mp1eWaQZNjMxH8QsFLDg+ua0ZTWLuED+rIO8G+Xs65b6sN7kw7vf
         o+8Q==
X-Google-Smtp-Source: ALg8bN4cqkJmiZ5gKghLT317LQQcjr7UPbsVs/swAEuVTEf/o6Id+B8XaQopKBWSE6zKZspIugeXaw==
X-Received: by 2002:a17:902:d70b:: with SMTP id w11mr24119215ply.294.1548718302803;
        Mon, 28 Jan 2019 15:31:42 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id e24sm41669794pfi.153.2019.01.28.15.31.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 15:31:41 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1goGNQ-0003H9-Sh; Mon, 28 Jan 2019 16:31:40 -0700
Date: Mon, 28 Jan 2019 16:31:40 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jack@suse.de,
	ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, dennis.dalessandro@intel.com,
	mike.marciniszyn@intel.com, Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190128233140.GA12530@ziepe.ca>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121174220.10583-4-dave@stgolabs.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 21, 2019 at 09:42:17AM -0800, Davidlohr Bueso wrote:
> The driver uses mmap_sem for both pinned_vm accounting and
> get_user_pages(). By using gup_fast() and letting the mm handle
> the lock if needed, we can no longer rely on the semaphore and
> simplify the whole thing as the pinning is decoupled from the lock.
> 
> This also fixes a bug that __qib_get_user_pages was not taking into
> account the current value of pinned_vm.
> 
> Cc: dennis.dalessandro@intel.com
> Cc: mike.marciniszyn@intel.com
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  drivers/infiniband/hw/qib/qib_user_pages.c | 67 ++++++++++--------------------
>  1 file changed, 22 insertions(+), 45 deletions(-)

I need you to respin this patch/series against the latest rdma tree:

git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git

branch for-next

> diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
> -static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
> -				struct page **p)
> -{
> -	unsigned long lock_limit;
> -	size_t got;
> -	int ret;
> -
> -	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> -
> -	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> -		ret = -ENOMEM;
> -		goto bail;
> -	}
> -
> -	for (got = 0; got < num_pages; got += ret) {
> -		ret = get_user_pages(start_page + got * PAGE_SIZE,
> -				     num_pages - got,
> -				     FOLL_WRITE | FOLL_FORCE,
> -				     p + got, NULL);

As this has been rightly changed to get_user_pages_longterm, and I
think the right answer to solve the conflict is to discard some of
this patch?

Since Andrew is OK with this I can move this ahead once this is
resolved, thanks.

Jason

