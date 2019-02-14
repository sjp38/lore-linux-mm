Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2DBBC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E17A2070D
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 11:29:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="J91kQpug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E17A2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DAA98E0002; Thu, 14 Feb 2019 06:29:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18BA88E0001; Thu, 14 Feb 2019 06:29:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07BBD8E0002; Thu, 14 Feb 2019 06:29:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A568B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:29:03 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id l17so1214146wme.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:29:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8y4n+o9Hv/codggya8emxwNTjOMFoKmC5CMGzEsB5lo=;
        b=RkSOCwRijQVfk8RBfrUn5QhhBbxEGglZu5gxVhIztXqsYJII1imi2ZTnm5ujDJKn/q
         7+bDagvcjRWsfCGckVTFzS5/er8VB/1UZPnMQO/P3Wh9PbCNqG/M2P7s7GWuVyxbOyql
         VDEmxG/dukTtD1PK/pN5neSZYv5y89LD+yuHcCb9jVeugks7qGt6nyoDKhIfeC2nKvGS
         6+KBd2E1BWvzG4RPfg5NRy/zilCXP6pw9TAHtUrIe0scGLHUrlVDQDONr5TLNCNVAMvg
         WHThcrA7ECPynjSfhqOqE/J6+0g3QUdSwe2s4uFRN8ulzJujRZCRi02NQEf6LWlbdXsC
         FRhw==
X-Gm-Message-State: AHQUAubc1puumHy1u8olV1aze9sHVFB5j0DyMc3hFvC72ehzYmJ8G6AB
	e7L5LwsWkcERzCzm3vM948O+lQknVjsnUaWnunRpzHePbOyXUQn5zheyT/uTVsvQrR8OaycAx/l
	5u81tXb1hlz9AFDX3djBgtVn5IBW/0s3bMsZCZC4BfhTRIgfZWTxrZhvnjiq5vFGVTQ==
X-Received: by 2002:adf:e641:: with SMTP id b1mr2373920wrn.213.1550143743061;
        Thu, 14 Feb 2019 03:29:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZRnaP8u57CwQ+ICEWd0zqLNts1MwpdPDxUzt/SfgJKzAHho6svJahz4NXlcvvvbyFuH56/
X-Received: by 2002:adf:e641:: with SMTP id b1mr2373858wrn.213.1550143742277;
        Thu, 14 Feb 2019 03:29:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550143742; cv=none;
        d=google.com; s=arc-20160816;
        b=u/7h9j0k/GwemZG/Wcg5HW1Ai0yuDquNetuDV+0As5HS6134cL37nKbn+xEWvcQwne
         GlkDTOUql3LSmQba2u5Z729t5W4WupYtmV5J9cKCQAoYMqpgMP8gx/bGHYXJMWNEm2ko
         6AkHOGLquH0Wgs7MZTYJc6hwPXyqf+FCSFKClngp1yfl5Cv4iEQdhhM4lxmQrqv8VoHw
         SV5pgnxsob/nSjmLh2I36VLIkzhiXDof6KqZ669W1l7B+6RyTImWZ4Alc7rkz8QJDuoE
         8aooIzxN1+StUD1OI7dB1mefgUwYBYTN4uVqE0SNBsQsSjnDbZuneMWQKJDWU1+RCxgL
         kn/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8y4n+o9Hv/codggya8emxwNTjOMFoKmC5CMGzEsB5lo=;
        b=qbDV+QU1wVE2png/HLRTQ/SISZkl0cW03ndIoH+eeLcnAfeaBTeGJNCHsX7BLsnMT1
         TrDCj/t6e6Ao3EP+R7cqo18bw0IV5lk6R19rDfCt2GCjq7FcM+QoA5V7mPbBT4tDqv7m
         QtidaZHVsKIl7kXtk1hxAaREWT5hHoPEFJze5PBe7LkOJiaKHeAtQoVfAxYjmxvd3Jy9
         +3P8t2TJ8+LrN6xehai5lv88T94m6DSe27jYbyD2jXOQ9zXQQlZr8AtVS2GROZ7y3fG2
         priV+cufm4/iGbIHjtbribJFx0I4QUlWwhbJWlY/wt8u49lUcbbr17Tnjp8RcadWkQuK
         P9yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=J91kQpug;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b6si1433488wrn.82.2019.02.14.03.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 03:29:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=J91kQpug;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8y4n+o9Hv/codggya8emxwNTjOMFoKmC5CMGzEsB5lo=; b=J91kQpug93gfsehaWqBdUaNX7
	zurTZUL4+JzzJoEFzinTvJLUcZjvtAzQUTAW6XGeEyeZYoRxJOdnXrn0XUqSbi8HIRM+3IZy8pve/
	4kk1Edp9RzAsItTLdw/hvdY5AwjqWP7RA9zA76VNIhGGFOPzHzvme8eEmjQia3qP3cNqAzFx/AfE2
	jwORxRGFCJSfSYkvbyGpUcJEvMsu5Ppy/zsm5R1ixltq5pbxTQ21Rkf4JKNFBDb7PHYcO8flecFDK
	896o1MiZPOaSslxF2HapiP0kq3xMZz+S9jbcKGCkhJ5SdRotn11e7eVeiITgcuWxWsGQ2GZKc17nL
	Mn0bIMNOA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guFCG-000270-4h; Thu, 14 Feb 2019 11:28:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 1DADA20298BF7; Thu, 14 Feb 2019 12:28:49 +0100 (CET)
Date: Thu, 14 Feb 2019 12:28:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v5 03/12] __wr_after_init: Core and default arch
Message-ID: <20190214112849.GM32494@hirez.programming.kicks-ass.net>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
 <b99f0de701e299b9d25ce8cfffa3387b9687f5fc.1550097697.git.igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b99f0de701e299b9d25ce8cfffa3387b9687f5fc.1550097697.git.igor.stoppa@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 12:41:32AM +0200, Igor Stoppa wrote:
> +static inline void *wr_memset(void *p, int c, __kernel_size_t n)
> +{
> +	return memset(p, c, n);
> +}
> +
> +static inline void *wr_memcpy(void *p, const void *q, __kernel_size_t n)
> +{
> +	return memcpy(p, q, n);
> +}
> +
> +#define wr_assign(var, val)	((var) = (val))
> +#define wr_rcu_assign_pointer(p, v)	rcu_assign_pointer(p, v)
> +
> +#else
> +
> +void *wr_memset(void *p, int c, __kernel_size_t n);
> +void *wr_memcpy(void *p, const void *q, __kernel_size_t n);
> +
> +/**
> + * wr_assign() - sets a write-rare variable to a specified value
> + * @var: the variable to set
> + * @val: the new value
> + *
> + * Returns: the variable
> + */
> +
> +#define wr_assign(dst, val) ({			\
> +	typeof(dst) tmp = (typeof(dst))val;	\
> +						\
> +	wr_memcpy(&dst, &tmp, sizeof(dst));	\
> +	dst;					\
> +})
> +
> +/**
> + * wr_rcu_assign_pointer() - initialize a pointer in rcu mode
> + * @p: the rcu pointer - it MUST be aligned to a machine word
> + * @v: the new value
> + *
> + * Returns the value assigned to the rcu pointer.
> + *
> + * It is provided as macro, to match rcu_assign_pointer()
> + * The rcu_assign_pointer() is implemented as equivalent of:
> + *
> + * smp_mb();
> + * WRITE_ONCE();
> + */
> +#define wr_rcu_assign_pointer(p, v) ({	\
> +	smp_mb();			\
> +	wr_assign(p, v);		\
> +	p;				\
> +})

This requires that wr_memcpy() (through wr_assign) is single-copy-atomic
for native types. There is not a comment in sight that states this.

Also, is this true of x86/arm64 memcpy ?

