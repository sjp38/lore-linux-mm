Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DC62C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A2C620881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Jk0fptbw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A2C620881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8ECA8E0006; Tue, 29 Jan 2019 05:44:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E172B8E0001; Tue, 29 Jan 2019 05:44:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D08868E0006; Tue, 29 Jan 2019 05:44:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 711DA8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:44:47 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id m4so7874274wrr.4
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:44:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/DYnSP8wwfkVagxlcXdbh9VOXn6NyWlZWTa5ybGjpLI=;
        b=T54KxV+Q+cjFU8fiGLzS+xLTp3rd2LOlCYwE33oALrI4NY18pbYked3hFBllsOnTLY
         le7jcEs8VF8mIO0pmKJrq4VRJUXLwXEv0/DsJup8XzSi1MupvdSW0W24tFg5iV0MFHVo
         t7uA7vTBDvUS+B4pTFyfbsh71GxsvlNU71NbWGYFI4RIxLnMchkHXFgmQ2C3afx+OHcb
         fc9Cy9shzFhV/brAoNGHVIGwcGJmSiNR2LzASKbP2QVQ6rSQTX7C6M0FSoBRSyDsYbvG
         nUpdwbLrGXIFkRlF+ks7mcoKMQ4lDSwLsjT7vaRLsDxpbh7fjr7M8exqacQ7gWlnmbed
         xgmg==
X-Gm-Message-State: AJcUukelVBwgejwbVKWxlcQ/rGyIWpX711a9KMli2JQAZghUHVvzi6c+
	dk/9saTD6xLwQ9B8VqYe4kmJ7zdgsoWjpExhZpN2ED/Y8qjiLXjTutslIrsbF0ua1HADVvmBEpm
	LYe3c6ukImiz1ZsqeXN98u4lJywrs894dBVFQ4N0tVbJHIx4Itsq3tFp0Qye3fISkYw==
X-Received: by 2002:adf:e9d1:: with SMTP id l17mr23763422wrn.73.1548758686943;
        Tue, 29 Jan 2019 02:44:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4ENZ4KWcxGYi8MoR2RP9HFtP10femQ1Cn0pgxdNTyOGhfIb2HRv462FX4COgCwv0J6gvmC
X-Received: by 2002:adf:e9d1:: with SMTP id l17mr23763374wrn.73.1548758686039;
        Tue, 29 Jan 2019 02:44:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548758686; cv=none;
        d=google.com; s=arc-20160816;
        b=OXR/AjlDfcSl+yTAiwHQUgEDBDg8KJ26WTeAFxFMe+43w34GOcN4wqkpUTXHtg6HZs
         EcESK0fgQH3kAd9oANuQuRH+ANzn3wnM6/C7x3Yo4MnM4+ig9R+V5/QGnyKrF2CjoHqh
         WYb7lX5rXUo6itjYXadFdDRN/0Fxo+Cux9F+MaKqy4Nk78WGBzAVNauZfmt1IjYh4oXU
         U4jYOGDF49RWV/Ff7aOZG/t6yQPOa2NAJpb+nerf4klv97yHmlHz1XSHgR2uBk7VhTNI
         9AmmFsIvBH+jq+P8gw7EQhTNRl71a5FLenHb4PEZygA4Zg4rPNGjDUSwYYXz8cgot71r
         zDYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/DYnSP8wwfkVagxlcXdbh9VOXn6NyWlZWTa5ybGjpLI=;
        b=LZTZKNZwp4V1Gp0KpK2UxYUNtA6yPFfRRldgbqJ+IW+m8facuHIP0E5HSgP9Z9fg8h
         tmihpPLMgw0QVndqFdp3sGG6qavjkTWEitgQEb0QhXKSZwsgJBcqzxQawhhlu4Gek3U4
         FuOpPTCam86AakFbw/HF5Kyh5NIDBc6IFgsILvryHqYqiiZRC/SBXZZur2TAOoxcpeH5
         A/faWgEwTpnbcd6j3nWsDecCSbYsVDov1ZYFWQb2Cjf82xHD42LWPnFuimcqv1VHBkkx
         j4rw1yebQBnTbxOebfZtb+ioRdmdKcz48yrsbyymVJpbKP5xpoR16+7GcBQkOQ9ahyXW
         dWpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Jk0fptbw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h9si1614431wmf.10.2019.01.29.02.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 02:44:46 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Jk0fptbw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/DYnSP8wwfkVagxlcXdbh9VOXn6NyWlZWTa5ybGjpLI=; b=Jk0fptbwefzDq9+8zgftkY20d
	8S0HjEYx3W+J+CiaW3yCBRQi0gRLhDpQapl661tD+UD51GNxqwhk4DCEsUZTZO0URngSGCK5T59xD
	JtGj8ZWFL4Jt8tnkbUuNnyncF4lIH7sm7URnzzp9WO0be1AhK4U0uo8lmZy3mtvJPMwV9Rutb50Sv
	DVZ2ZTggkXUTqp2XPUldmoZJG04oFmB+wx66t18Imh0r+agjQTCJ0aK0nGIgFR9aCVHnHx969KoX0
	bG7U89mBgq3HA5cZqmkgbLkeTbk2UYHcFEhwAAs7mfqs7H41qw4fuQGDYKzQ+KPu/p4uasxvQIGQh
	D0KFbAGpQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1goQsa-0000Kv-H3; Tue, 29 Jan 2019 10:44:32 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 4EECB201EC171; Tue, 29 Jan 2019 11:44:31 +0100 (CET)
Date: Tue, 29 Jan 2019 11:44:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org,
	dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
Message-ID: <20190129104431.GJ28467@hirez.programming.kicks-ass.net>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-6-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124211518.244221-6-surenb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
>  static void psi_update_work(struct work_struct *work)
>  {
>  	struct delayed_work *dwork;
>  	struct psi_group *group;
> +	bool first_pass = true;
> +	u64 next_update;
> +	u32 change_mask;
> +	int polling;
>  	bool nonidle;
> +	u64 now;
>  
>  	dwork = to_delayed_work(work);
>  	group = container_of(dwork, struct psi_group, clock_work);
>  
> +	now = sched_clock();
> +
> +	mutex_lock(&group->update_lock);

actually acquiring a mutex can take a fairly long while; would it not
make more sense to take the @now timestanp _after_ it, instead of
before?

