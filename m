Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D34DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 12:39:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8B172083B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 12:39:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PBeiAFj8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8B172083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22C3D8E0002; Tue, 29 Jan 2019 07:39:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B26D8E0001; Tue, 29 Jan 2019 07:39:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0541E8E0002; Tue, 29 Jan 2019 07:39:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B322F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 07:38:59 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o7so16711972pfi.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:38:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hcUmsWqOlUZoA0tGVtVxZVeGi9/WntceTQMLGURqW8U=;
        b=t7zeDCnZqzU8n0rnApnztPGkPIZhufTkRGT5olmGxX4rpyuNfDLva5NA9FNoN7n+Oy
         lkEqx7TW+Auq8O3VF4oGmH7w29P6RbrOaZ+CgCEVZ7Ug0UMHIQMJAgFZy7SC77NBqJ3P
         zBtNgkdAPr7j2v9kiEyzM15kGvWN2h2ygjTS1GG9NjJymD8TK00Sr+Hrp3fGDuYPQ+g3
         lMK4zN5A/xpy/WEINTHjfFEE2uOsnBWFdqovrCur8O1quXwft0edfGgWEBTA0yR3tkHS
         MAYFw9riKBVgqV3Aur2YjuN3qzPR0cImuoUbT/JXz63zzmVJRGDGBYJyjvRleSf7HjpT
         Q4ew==
X-Gm-Message-State: AJcUukcKfIIvADMuJlZpIDsaMxskDUiwWm9/fhZNiNbUG30buCkxqhir
	+XN2KaWSiu3YbkoHXcbFr5X/lAG5b0G0ffvRYPjJTD1fA+cytcWKcdDeKCMVrINW2VKn5HJIYnJ
	ola6XQfBZHXD7GPz/5puEvOtOtATF37ljIKyKjQ3uOX85OEtflZnG4fjTYWnrnAEbaA==
X-Received: by 2002:a63:4745:: with SMTP id w5mr24039979pgk.377.1548765539329;
        Tue, 29 Jan 2019 04:38:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN65JRyDs0QMm9Arplnr3rojCx5an5ktI6/vWukOA1pTnh/c0W5uuGoofQjw3qKW6LK5htBQ
X-Received: by 2002:a63:4745:: with SMTP id w5mr24039931pgk.377.1548765538252;
        Tue, 29 Jan 2019 04:38:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548765538; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+/osBiYbLnlqIBtW2W6dKp7CKxVSq2S6vijNnx9OQ7wTUWMAfYtaXtEyPUvV4uTg3
         2L21RLtBfuVCEBt0fnnJGTOra75FXqq0mjXCEvUZ2IJzDCX3d0fHgEcD6diuynFyusgT
         z7fT9qZn3IkPFBWUFNZSlz5HinvQ/z0+XkVcbRfbZsFiPRxQUQond9JlaYCzJOoVeEsb
         ieGj8meDbbFrz8r3i2kreTn8+X9f5l4XwCsTjIsEWfcEQ4sWNvrGUx6KJ3tWg1oYrDNc
         fbipsEsz1jmVhJ9QpOWH0kpYaQTpD0MXS8UdUVaCJtUtMpPYpFOo0IUyigbihHTo+YOc
         +yDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hcUmsWqOlUZoA0tGVtVxZVeGi9/WntceTQMLGURqW8U=;
        b=ALhLdBh24v4ea9hBMuR1PTiAyYLb7U4YEOomL9lk0I1iejpaZ3SJnhcc9ONRH8X2yB
         TUCBJ5M+YRSywtWiEuq81ZuyJPrXZT+gGyHbN/AfL45S6f0qfIS5utdUn1Lz64rUmWdG
         Bj+kgWotlyrhDYx8OSEbX3TzwcfLHsZe7+unRZo1PbG6xZtQE8R7ojq/SftvEeElL0bp
         BrqBhyI15PN0fTOgPzaNFD/LLFW5+aiEfZBfE/OdduRF1DHXsz63QJ1E+DJGCUPURjRT
         KPDrjsxasg14ZoYa43N4VKwiEXBbbmkM+mYXLVOb2L/YW898vbNi8e83lIWRHf2R+Oh+
         pD6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PBeiAFj8;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j20si5485962pgh.224.2019.01.29.04.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 04:38:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PBeiAFj8;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hcUmsWqOlUZoA0tGVtVxZVeGi9/WntceTQMLGURqW8U=; b=PBeiAFj84XF4ohPPYvNWj4Frx
	zy33xge/EQv0zpd59PDLm9VtSeIzpXE/lJEW4322H3P7tFLk4zvJP6dZ4NEifr60zfHbqnunPMmh7
	BNEYVN7SeJ/JCiD5JBo3xBvAF9RI/9ho2qVbgzxCcw6ZhcIBUooP2sen9hW8s1fkr46WXVF8hVJlj
	a5nWrftCspTUGFGV3K0hjkbch5lEitgg+JzHUbTusZps2AsgxgAaYnQ5ToQnDYoMaaPIXiscx/v+o
	t6qBu0lTsYS/Iq+N4raF0oQZ+VLiBr7q1ajxAP7N6NplyLoU7Zvns33ALWYK968MQoCR7KZslxNfw
	CmIApdPvA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1goSf8-0003BI-LX; Tue, 29 Jan 2019 12:38:46 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0A4FD2042CFA9; Tue, 29 Jan 2019 13:38:44 +0100 (CET)
Date: Tue, 29 Jan 2019 13:38:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org,
	dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
Message-ID: <20190129123843.GK28467@hirez.programming.kicks-ass.net>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-6-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124211518.244221-6-surenb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> +			atomic_set(&group->polling, polling);
> +			/*
> +			 * Memory barrier is needed to order group->polling
> +			 * write before times[] read in collect_percpu_times()
> +			 */
> +			smp_mb__after_atomic();

That's broken, smp_mb__{before,after}_atomic() can only be used on
atomic RmW operations, something atomic_set() is _not_.

