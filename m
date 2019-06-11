Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C78BC0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB89B20679
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:55:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M9Z4LDyf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB89B20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B31F6B0006; Tue, 11 Jun 2019 15:55:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73BC46B0008; Tue, 11 Jun 2019 15:55:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DE596B000A; Tue, 11 Jun 2019 15:55:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 262A26B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:55:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so9768534pgk.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:55:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AwCIOFChcpLV9jmax1ImmjMnCxcc76+OXa2FfkpzRbI=;
        b=escc6urO3U03v87lUVhycAPDAcxboUEBKic7u/zdVHLmuaNYdI0HRI+8Mm+1HAJn6P
         05XNCbCfAF0sbj7rZcm1btPq06vNAeai8WbvA9E3LZP6SiZgnKh5o9McGBpXvs3i4PF0
         8UIuPbs2d4NNam43jJt+96LwbtdSSCeWMpHU62Qa9Nk81cMP86Q3i2ZJzk8juKKrYjUJ
         x+Cr/6giX6DKjHxBcPjIdKrazZAIVJRA/scRjHYz5qhc7XDDE4zbF7OA64V91ncXCZWg
         aAguVqGgIXwR1UoaJWZgbM/q1CE+MaUOL64JfxxXPDSUgJWTU9SGDfUDCvcbHpX3T8Sq
         PSwA==
X-Gm-Message-State: APjAAAXeMBVcb2TfdX/SZC++DXE/FNShhRTx/UYtjttUiAC752CUx0QN
	adBaOEoXqp548UtZkW+URuuzzTRGtqBHN/PzMDn03G8H1AJEReutwaE9xlCx5EgMGTGDbCjbE9j
	tBjs21a3rsDwKscZ7ET0E6ebYVwakig7Znl783NkXu/skfDmsKG03xa5VrG+rBgY=
X-Received: by 2002:a17:902:8a94:: with SMTP id p20mr58569174plo.312.1560282953751;
        Tue, 11 Jun 2019 12:55:53 -0700 (PDT)
X-Received: by 2002:a17:902:8a94:: with SMTP id p20mr58569113plo.312.1560282952972;
        Tue, 11 Jun 2019 12:55:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560282952; cv=none;
        d=google.com; s=arc-20160816;
        b=j2nplH8ic2QNxxs/+S44YTXQ7uWmaaD8uuzkjtVxHSAhwRCJGTRlMU6uaojbaNsS2N
         HZp87cWPJj3Nvuq8zwn5nRT4JscU3YoMN7UWKVlcn7J73oXqui/CV8FaRHXd7hGBiTLq
         vmuvsoUng9trmqyiXPGLOXi6ueU+oeY55EY/YD/dZsJS53PI1gfBdrwuYSly2Or4fOn8
         c/mpglCHs2DYInPWQ+4/R8LFj+iosAwY/Oi+KZPFe1V+/yWBhN9h+9oc61OlqLQxs0t1
         b22qT7PxTxoWLNOmXU60B+aumRfG0zI7FhcU+91sokXz/e/6bYYcYeYnx+zyfuk6pXn3
         ITWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=AwCIOFChcpLV9jmax1ImmjMnCxcc76+OXa2FfkpzRbI=;
        b=XDTNKIkGlDMgJU55JKvIUKU5e1S00TdcYjmJzDvWvRnhbMa+8WkZ2cSWKI9DRRZEx9
         RWpfUgylnxBws4vL7jT88GCKW6NuzTUIjSO2C3p7HV45UfgcLrU6lY2SaSucetdIXuHI
         rhi1hRZp6d8CEaXnbMcLMO9OFEpA6xNUAq2+u9GXzFxPGbKaAi3x44tz1rZCEPzD7ahn
         1DpZEUeQKs//Dn4MUqDHmq41di31tMoNg2F+y9SpGDBYxLWqvRhYIenSvEOMtV/oVSbV
         FSt4vTGRbcNzfaAa6VUhU2IVpJKi/TUisMPL02Y1vNSgTLFwNpqnwLK7fGErIRci9lIu
         YQEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M9Z4LDyf;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ce5sor16183503plb.17.2019.06.11.12.55.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 12:55:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M9Z4LDyf;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AwCIOFChcpLV9jmax1ImmjMnCxcc76+OXa2FfkpzRbI=;
        b=M9Z4LDyf9SZZLX+d8CLiaU1622gjvuImt3hgOgTYF2aM+GSl0AKsuxaM4G0Of4fQYH
         bV1tH5bOuSISTn6BvaZWTPMZ61j8tdlblPxANEmHu4dHb+K2/Nb8rXPQXf+d0yj/iA4G
         zdZXb+Tavk9kH5/1IApep03ogPUtZ3a8dntz14yOU4tABUdlci1Etq2OELbaeHGQxhdt
         0AhAsXZHBu3i5/EHAds23Y5tIy86tRFCy7esVxwHdzhzrZ1+5l8/WwVhL1qdEe/mOG5r
         8olwrJbO9oO1VXfufZSI7X/eJtOdsyQWzv9g+iTH6uKOQHboVP4PlxGpynBp/2YzJ1ek
         2GmA==
X-Google-Smtp-Source: APXvYqzSML6oqxdWG8320UlbIzvjIXhb8GAWGH3LMdkVr7d+A1ePWy4coBXTLSk4rXZK+TEhlifpgQ==
X-Received: by 2002:a17:902:54f:: with SMTP id 73mr76300723plf.246.1560282952464;
        Tue, 11 Jun 2019 12:55:52 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:1677])
        by smtp.gmail.com with ESMTPSA id d19sm2990693pjs.22.2019.06.11.12.55.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:55:51 -0700 (PDT)
Date: Tue, 11 Jun 2019 12:55:49 -0700
From: Tejun Heo <tj@kernel.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
	bsd@redhat.com, dan.j.williams@intel.com, dave.hansen@intel.com,
	juri.lelli@redhat.com, mhocko@kernel.org, peterz@infradead.org,
	steven.sistare@oracle.com, tglx@linutronix.de,
	tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, shakeelb@google.com
Subject: Re: [RFC v2 0/5] cgroup-aware unbound workqueues
Message-ID: <20190611195549.GL3341036@devbig004.ftw2.facebook.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
 <20190605135319.GK374014@devbig004.ftw2.facebook.com>
 <20190605153229.nvxr6j7tdzffwkgj@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605153229.nvxr6j7tdzffwkgj@ca-dmjordan1.us.oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Daniel.

On Wed, Jun 05, 2019 at 11:32:29AM -0400, Daniel Jordan wrote:
> Sure, quoting from the last ktask post:
> 
>   A single CPU can spend an excessive amount of time in the kernel operating
>   on large amounts of data.  Often these situations arise during initialization-
>   and destruction-related tasks, where the data involved scales with system size.
>   These long-running jobs can slow startup and shutdown of applications and the
>   system itself while extra CPUs sit idle.
>       
>   To ensure that applications and the kernel continue to perform well as core
>   counts and memory sizes increase, harness these idle CPUs to complete such jobs
>   more quickly.
>       
>   ktask is a generic framework for parallelizing CPU-intensive work in the
>   kernel.  The API is generic enough to add concurrency to many different kinds
>   of tasks--for example, zeroing a range of pages or evicting a list of
>   inodes--and aims to save its clients the trouble of splitting up the work,
>   choosing the number of threads to use, maintaining an efficient concurrency
>   level, starting these threads, and load balancing the work between them.

Yeah, that rings a bell.

> > For memory and io, we're generally going for remote charging, where a
> > kthread explicitly says who the specific io or allocation is for,
> > combined with selective back-charging, where the resource is charged
> > and consumed unconditionally even if that would put the usage above
> > the current limits temporarily.  From what I've been seeing recently,
> > combination of the two give us really good control quality without
> > being too invasive across the stack.
> 
> Yes, for memory I actually use remote charging.  In patch 3 the worker's
> current->active_memcg field is changed to match that of the cgroup associated
> with the work.

I see.

> > CPU doesn't have a backcharging mechanism yet and depending on the use
> > case, we *might* need to put kthreads in different cgroups.  However,
> > such use cases might not be that abundant and there may be gotaches
> > which require them to be force-executed and back-charged (e.g. fs
> > compression from global reclaim).
> 
> The CPU-intensiveness of these works is one of the reasons for actually putting
> the workers through the migration path.  I don't know of a way to get the
> workers to respect the cpu controller (and even cpuset for that matter) without
> doing that.

So, I still think it'd likely be better to go back-charging route than
actually putting kworkers in non-root cgroups.  That's gonna be way
cheaper, simpler and makes avoiding inadvertent priority inversions
trivial.

Thanks.

-- 
tejun

