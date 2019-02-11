Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85EFAC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:54:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FA9C2083B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:54:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nj2aEaoW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FA9C2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB4C8E0187; Mon, 11 Feb 2019 17:54:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6A978E0186; Mon, 11 Feb 2019 17:54:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A80628E0187; Mon, 11 Feb 2019 17:54:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68C308E0186
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:54:50 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b4so487655plb.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:54:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Nnjv+ROc7ciGZ5xFxjkSbI/QboRe6hPG4YjtEvpy/NE=;
        b=Xba7+QwWbdV7BtKrsDgUZ2m4SytML3ozZJkLGzI6lFvqba/go9zHXcxScI3TW0/IfW
         M83Hq3v6PaV+qj9nJNBpvu2zGZhM+bu5sk7n8Hc7jw6s3NHoj147Aex9VlcJwb2Uj2EE
         HDdc0n1d34ynHl13MPbeEwGUg5Q3UZ3iaxIZS/8oYcgzVlThcxS99xo8SYNFt+GyM/JD
         y21WkY2FciMmItZncSUfUc2O150kJpgY+YjZeIZVgESuv3XLPJSaXxpP6YX13/2HH5nk
         h4dWMWsD3F/6F2b9QmAQAcJL0gvBCt6RezTkNrMpyGwn3lJagq49uoXD48kfJGq5mnkq
         4zrQ==
X-Gm-Message-State: AHQUAub/ZMRiXkE9K4gFYrGX2aVEuwJtm7tG3ePB2E2PM0wPXbYG1lDd
	pWgEVcU3ra2ahumYp6cM/uTWwX/3AHFgyZKBMtlxltNs3F5NJGr41WtABkmVugDezGNWvhK5tKy
	AvRQVAuChRwJmGuE1flH7YhhRB9cA0lmjW2tkLIB8P/MJPhj/XRfr0PWE9/SHXDr0reDkk3LHuF
	o6/FGEvKR6Zhnscf5y6e3cQFgjnxTsd1LjZF1xvi+/5xLs6XpbquXwyey7/E+zY3Z9ccx8GS0QM
	h5/a3HCcQ2BHV1DVyxQ8AgCSY2Wqtn//q7bwBbKVTwYXGVp7z+P+R+1xzCib1whUUUtkbF/f0RI
	9iYr6ojE5QDNKCzfPU+GD0KL+2DJb46gAkHoz1T/rZAM6MmVRTXiWOMMzZN7/zpBhle0pe8dQYk
	m
X-Received: by 2002:a62:5789:: with SMTP id i9mr644101pfj.75.1549925690033;
        Mon, 11 Feb 2019 14:54:50 -0800 (PST)
X-Received: by 2002:a62:5789:: with SMTP id i9mr644067pfj.75.1549925689501;
        Mon, 11 Feb 2019 14:54:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925689; cv=none;
        d=google.com; s=arc-20160816;
        b=xSXWv0AYH8xZjuae9U581Q0YTHFCybxIrMAAdrr8i+GzaGUcsRdRWAH7zAfZhmCjZK
         zQviTMu7go8VSudzOBi2vmO6bO1dJ1uKGXCVIHUtRYC1aJU4wSS3HyKgTBZVdn3RVazo
         i3odwOmcLe13nPFyyW0Jpec/R7P2Y4+pLAf5P6hDDN9pgQ43wkMkBm18q8bzfVIW7/QM
         lCIRkyxhSkLv1CU4DMCDr50te3M/R+Bx3Gu/z8lHBVU7ErCU1l4J1vtz8tz5KflHi09e
         L43rqUxg56rztqvngshjGHBJzlI6ivGyVzKZh6t3iThptES0YzAmGmw0ZADXLT+538qM
         hOiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Nnjv+ROc7ciGZ5xFxjkSbI/QboRe6hPG4YjtEvpy/NE=;
        b=Tzu1n0tdBzCmA+Ydyf9bHQiM7D0doMIraG8hhtrdm/uWiNxPsAqqwoeVY/QgKVuUC2
         NqQ6dIl32Xy02vOA4JC82cCrZNtML3RH5G7vUjSjvpJGtP3c+Jpn1lh54W+xuEAq2B1o
         jDxOyjH2fMibY4mm6LAgAJ+ntv/kYoeDNK881kB2GOXQR6jOwkyPmW9o+MK7qkgOPvga
         /c1wdQILWrB+q9/rDgdzgWzMgMYGG8OZXKQFvC9mxy+vRBLkA7TXUe4q977TTvUZ+sEa
         Th2iCGvxr9bAVlGZBIF+fRB2YBuQP1AjGeEom6tPIqpWyBSUkb/7rjPflOWGKuB5vVgK
         vCeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nj2aEaoW;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2sor4723681pgj.23.2019.02.11.14.54.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:54:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nj2aEaoW;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Nnjv+ROc7ciGZ5xFxjkSbI/QboRe6hPG4YjtEvpy/NE=;
        b=nj2aEaoW6CV4dj7N/6ZjXb/iKW8uostTzcE2RJ7/dU28IxKQM0gsJiKq5yyLrtJccq
         tFHOlbx+DBFlEIqVzzEoZ3BpR0DS4D6JClryC8gcvfeXkmnAzc6trASgatfSpRtzBPKx
         XHVwh/d+DXn6bWJekIyggMOq43FhS2oa6VyKjcsi5dvSUU6VEdJ5ASrlnT8Tmikftc5b
         uQX4mGpcXUmDnN1OqLRNLFvtepie6LyvV5ACs+iePwcnbMdDi68KDl3mHdpGNMh4VNUj
         NoVYrB4vF+v9jVKRtPTgAFLZxm55YNqmGmKwpvTZsmD/99r5AYCgAPzRpYq23mlwAQXa
         UZhQ==
X-Google-Smtp-Source: AHgI3Iay4O9bB9n/pGpyk1kN1tV8bWoIAGTYBHJeUZ6apBJpCJJ/V04jDSGkM/rSMYCK63GYv00hlg==
X-Received: by 2002:a63:4658:: with SMTP id v24mr635737pgk.114.1549925689039;
        Mon, 11 Feb 2019 14:54:49 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id t3sm2392772pga.31.2019.02.11.14.54.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:54:48 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtKTP-0003RY-Pa; Mon, 11 Feb 2019 15:54:47 -0700
Date: Mon, 11 Feb 2019 15:54:47 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz,
	cl@linux.com, linux-mm@kvack.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org,
	alex.williamson@redhat.com, paulus@ozlabs.org,
	benh@kernel.crashing.org, mpe@ellerman.id.au, hao.wu@intel.com,
	atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190211225447.GN24692@ziepe.ca>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:44:32PM -0500, Daniel Jordan wrote:
> Hi,
> 
> This series converts users that account pinned pages with locked_vm to
> account with pinned_vm instead, pinned_vm being the correct counter to
> use.  It's based on a similar patch I posted recently[0].
> 
> The patches are based on rdma/for-next to build on Davidlohr Bueso's
> recent conversion of pinned_vm to an atomic64_t[1].  Seems to make some
> sense for these to be routed the same way, despite lack of rdma content?

Oy.. I'd be willing to accumulate a branch with acks to send to Linus
*separately* from RDMA to Linus, but this is very abnormal.

Better to wait a few weeks for -rc1 and send patches through the
subsystem trees.

> All five of these places, and probably some of Davidlohr's conversions,
> probably want to be collapsed into a common helper in the core mm for
> accounting pinned pages.  I tried, and there are several details that
> likely need discussion, so this can be done as a follow-on.

I've wondered the same..

Jason

