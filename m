Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B19BCC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:03:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AA1E21852
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 20:03:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Tiln9LxM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AA1E21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D632A6B0003; Tue,  2 Jul 2019 16:03:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D12C98E0003; Tue,  2 Jul 2019 16:03:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C00D28E0001; Tue,  2 Jul 2019 16:03:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8907F6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 16:03:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so51984pgh.11
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 13:03:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Kcly/tuUbH1oIMLuOpvBwc3nXKhDlCKcUqNazXXJwlI=;
        b=ujJFF4B+OovGGAlq7T2QyjxeFIFApf8k/q4bzu5y0FOVgynhcD+RF+5pdpDEFl1qo1
         YJg6UlQfEVJuBh7UHVbnwODKE/zjJaibl+16MQ44ZD+RdYDUnmgHjwN0dIqe/Q5cAHRV
         2g4vTz4wEiee7yvoUlDk7SRFdQMLPMKcryqWN87JB301tCWctU7E0gVRpUPt3fPqUWbV
         +ywHCV/YZhX5sam6CZkUZPWPDgnyTHa4p5vLPM8UHiZoe0ivHHeY/zK7JyGAkmeNrzHO
         YDzj2n8TRPnCVL/xmFr3GJSQG2S8FzL6X/Dv0GF+dq4FBvQ7A2h6CeG9zjpGctGFdb4i
         jKAg==
X-Gm-Message-State: APjAAAVlluul3611cc39zQRf8JgIsl2L9n5IQX+v0IrReY5Sq8TOWp7k
	uylqDbTy0AGWTJRwEcLIwBzSuzBiGZ5A8hDmpnI48EPcj8ab9lx3QvDI8WzvRHjipC9Zv0l+B40
	SEcIWPANWejuxZW8YaNa4nUGVVdUpsu57BCjQsTqLmzU5xj5hYBt1V5WxOsy5gMwfpQ==
X-Received: by 2002:a17:902:ac88:: with SMTP id h8mr37601390plr.12.1562097801166;
        Tue, 02 Jul 2019 13:03:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtoRhYyZmCaxHhvdyOZoO7ejF7TSsVRCMVcezdrDRZOgrUS0IwffkCi7uHQMj0NGTbEPJ3
X-Received: by 2002:a17:902:ac88:: with SMTP id h8mr37601333plr.12.1562097800371;
        Tue, 02 Jul 2019 13:03:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562097800; cv=none;
        d=google.com; s=arc-20160816;
        b=PQKKWa0+Y5XBZL//HGGYYDvu8l3voqscJw7+3XuccAQfKEh45FWSFVOx+fBEVo3NL6
         nm1p7fHqR0tv7M0dWJRNxa8A+mIIs+hxk3XOfl+LJqm9bk0iq82uXwA6mWZy7L9zrAD+
         rQzZcldXIQWu//Q55G38tNLXF8c4sxNWEjO2RGNSAzCQtuJef8yywdM+z8vh+998ZVBz
         lIP/pGp4/A+gp94qftS0jIxLVy5qcye4U+BTZgpjUg8bXsTaxXoWdyg8tsbCUWkS1QlO
         tDP7bP1JJYkQGeY/HOTLlEP59aMDVqrBtnscRj3US7CO5MbGtwn2eZJ5Q+omokSBP9I1
         R0wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Kcly/tuUbH1oIMLuOpvBwc3nXKhDlCKcUqNazXXJwlI=;
        b=S9fAcdIKhjTghR0ThEYGGsBg8qCw3SLHIWg3EEzuXCIu0K5LgBgumWU3NKdWqb8mGU
         7QFOQVGo2lo+oT1kT4ecDNIiRSesDHzNDLMI641j6MoZUjTsU07EdSY+A2iP9/2STo4t
         dvkgAJAY6nv4+8+69BJOHIr1fKDnsNvojKfN+hVbakgFWULbn4+vY2pl2f7OyNOh2QzC
         OWTY2Rh6r2j8fqGHsANxbpYluD7lKCTNogyBepQNTlV4gkualAt54FTqK4/gwX6Kr4dL
         hUlyXCC989+B+spSBZdhjNIuWQLs8HS5bsiRZTWhxm9Jl3cPxuSRGLkipS5UTgdnEzAw
         Omlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Tiln9LxM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t14si15510110pfq.88.2019.07.02.13.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 13:03:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Tiln9LxM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 662352184C;
	Tue,  2 Jul 2019 20:03:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562097799;
	bh=kyfxYTDfXVVYVh+jLp8SPqoH6e+/on1CISn5rmKjOZ0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Tiln9LxMX1fNAo2/Ddp+J6EQL7IwtJ9uvLaA5tNsAMv7HWx786TfZZ+Zg2iwEa3zy
	 7DBc6NmB8eX7vXDjNIm9YVca7qmERe9+BWTzyahQE+3k8jNzrBotulWcBmvPHIX2uk
	 qZiUwdYXD/LKMhpngm7ibkztyOQiF7ErCvRr6OuA=
Date: Tue, 2 Jul 2019 13:03:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin
 <guro@fb.com>, Shakeel Butt <shakeelb@google.com>, Andrea Arcangeli
 <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
Message-Id: <20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
In-Reply-To: <20190702183730.14461-1-longman@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wrote:

> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> file to shrink the slab by flushing all the per-cpu slabs and free
> slabs in partial lists. This applies only to the root caches, though.
> 
> Extends this capability by shrinking all the child memcg caches and
> the root cache when a value of '2' is written to the shrink sysfs file.

Why?

Please fully describe the value of the proposed feature to or users. 
Always.

> 
> ...
>
> --- a/Documentation/ABI/testing/sysfs-kernel-slab
> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> @@ -429,10 +429,12 @@ KernelVersion:	2.6.22
>  Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
>  		Christoph Lameter <cl@linux-foundation.org>
>  Description:
> -		The shrink file is written when memory should be reclaimed from
> -		a cache.  Empty partial slabs are freed and the partial list is
> -		sorted so the slabs with the fewest available objects are used
> -		first.
> +		A value of '1' is written to the shrink file when memory should
> +		be reclaimed from a cache.  Empty partial slabs are freed and
> +		the partial list is sorted so the slabs with the fewest
> +		available objects are used first.  When a value of '2' is
> +		written, all the corresponding child memory cgroup caches
> +		should be shrunk as well.  All other values are invalid.

One would expect this to be a bitfield, like /proc/sys/vm/drop_caches. 
So writing 3 does both forms of shrinking.

Yes, it happens to be the case that 2 is a superset of 1, but what
about if we add "4"?

