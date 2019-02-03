Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F951C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 06:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB7952083B
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 06:21:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="fG0rb3LA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB7952083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33CE88E001A; Sun,  3 Feb 2019 01:21:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EB5B8E0001; Sun,  3 Feb 2019 01:21:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DCDD8E001A; Sun,  3 Feb 2019 01:21:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB95F8E0001
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 01:21:20 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t26so7920083pgu.18
        for <linux-mm@kvack.org>; Sat, 02 Feb 2019 22:21:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zxEjaYy+JsHVGX0Na5H2IIsv1IZR8sj0qq1XGIVMrvc=;
        b=NIF8Gyo87/EGAoONkpFQW+RBgWL/xjtCAiSUllrhWWwGdVxz8G5QPYifr9rTCRCfQo
         z+eOMpxXU1X+DC8PbQbqRz/ablYPYmKin/IazxssE0fXkJamiBAWnHQoRY1oAB7oaD/Q
         8oVs9wEYoHvaT2eXj4KEZeZzz7d7TavuU+t+cmo0aKcdh1BRwrIrN5GJ1xT/1BIzFZBB
         pr6gxnPUfmjnX3T7bu2WTGBIMSWI98BitgVQkPOnYLxU5I9vM28SyHvJ6asiDGrXyD+x
         zmVDOn6CDw+B89w103azbtVlCCE/YqZv30wxuFkCtP9kA4aYQbn0DzdAwq+PcuwMrPo7
         sdcQ==
X-Gm-Message-State: AJcUukeXGPCGw1VRlid8Y9dBS4Z8kRlpCyVkFLksGLwgsUHYCisUpW9c
	AWBLTY/RGGxPwkdyNC1I++TuhfRFj8mmxlFggMmf89/eQXe11yl8fUWlsjI0+F0BdcGLdb8SaQX
	tFS2arYYoFU+VwvUDsV6FiiCke5+/9a+PL0GRoC9jvmCMoa8Elex02ybBepobmnXFuF3f3015/d
	hrjUwSWfXaX3eoJS2mewTDWXyN6qRRBqfVQ6RNry7PUExPRiK7f7w4lU6PKTcgVDqpfIVhscJEU
	a+6iGJbl5rImlka2bQabkaZoUeIjnC+o64pCwY9vuicrzl6Wl7lNoC+JLdH5QTYdbghN73kdUHT
	AvTXIG/GpYS24n3//HA4TcTlrPR33gO+y9cZ/3eS4Py8YMUtiSeWX15as+A6FtaVH0pY8NGd98M
	s
X-Received: by 2002:a17:902:b112:: with SMTP id q18mr46752880plr.255.1549174880022;
        Sat, 02 Feb 2019 22:21:20 -0800 (PST)
X-Received: by 2002:a17:902:b112:: with SMTP id q18mr46752849plr.255.1549174879167;
        Sat, 02 Feb 2019 22:21:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549174879; cv=none;
        d=google.com; s=arc-20160816;
        b=w1FJ1TsLmJ8/ELXWsw5ngrCUd5ezBUSjxbbjD6gCYEZfj/xK0YTPGwxxBiP3i2nzs0
         9V5PdInzQMgkmw+8En3u6/fDVV/mJq0ZOJgz0o4fjXIoWR7o2i31YJgsRC9AwqrqfBXI
         yIA2e0vEKXofM+VZVePCfXYxgpO76OuaMS7eoW7FO8X2Yf7ilW5wiPCFwFX5d30APCtX
         debsH2+HROKxdSkFUQ5iafRBoAOSnKZ9txyEBXEiHlVHwaUacOD/LxvN7NflJ/WjYM8p
         W+kBZE8yiFRKhhs7GjsR+Mfg8SfohPGoLiq+BkNib95bmApECZXG7qkfs8lwgvnRG1gK
         sPrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zxEjaYy+JsHVGX0Na5H2IIsv1IZR8sj0qq1XGIVMrvc=;
        b=EzLqEVO945LpoxYJNAf4L/uvfJfYN+DVFIpkqUHlyvpR6ttQ///cebMA3e2XLOacyL
         AR01gmtdmZ5yKyERoDntnVYIPHeuci2UNelZ8qWu2plair/YtmpENAsEE6RMDyrqpVDM
         gsrAaGHTAnMs/gx8fPCzvmGzpndAD6Yl1xsRdE3gNBucVlZHEKT9RZ5epWwqXpaAwt9c
         8dcnWxVhiUCxTxz4pHxNm399vwrF0N83t9sUZWuzQ2jkFrk1EjycKgNmYP5N4Dyn/MQ4
         aLf8YLtJVa6NudegcsHGv+1N4Y6/AsadZBvFW5FodxHx6uqMN4/Bx1hYS/xO28HDJSTO
         JVbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=fG0rb3LA;
       spf=pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor20225461pgq.46.2019.02.02.22.21.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Feb 2019 22:21:19 -0800 (PST)
Received-SPF: pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=fG0rb3LA;
       spf=pass (google.com: domain of sspatil@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sspatil@android.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zxEjaYy+JsHVGX0Na5H2IIsv1IZR8sj0qq1XGIVMrvc=;
        b=fG0rb3LAqiMpw7kMFwZ2BqmN+BqjEcdKYjEwk+719BDaGX2DDF+Ly5rzNkp3AqyhKn
         UJM5r/O0RYpLzy126uMJFnu8UwXBcCWc0Y8cMCrywuAhOH2V+K7epx1tX+HJHZkbgQki
         QdZoDwDErh7q9JtPlJVEwkawEhLWhCJtOFaGQu6maez7E0WLOaqwE1RuUq7/GmLLL2Lq
         Mhcg0zty16Xbe0JfAYrZXt6wMjt/vT1Mh5+t88nK4tE+tKnY8+pPdm2AHV+8F+R5iYoL
         SJ87J5Z61dYAPfFoxLu3Z6HxkKut4q//qDX8IVL/JYLBXW468qmOg3nIAlKLd68g8kvB
         U8sg==
X-Google-Smtp-Source: AHgI3IZOb1aucWJvwRr4/Z8hFCdTydsb5pBrcyfqrHvEkfsKKkIxmY54b19zR7PSqeLyrCvPB3v7Xg==
X-Received: by 2002:a65:448a:: with SMTP id l10mr8595082pgq.387.1549174878794;
        Sat, 02 Feb 2019 22:21:18 -0800 (PST)
Received: from localhost (c-73-170-36-70.hsd1.ca.comcast.net. [73.170.36.70])
        by smtp.gmail.com with ESMTPSA id y12sm18425995pfk.70.2019.02.02.22.21.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 02 Feb 2019 22:21:18 -0800 (PST)
Date: Sat, 2 Feb 2019 22:21:14 -0800
From: Sandeep Patil <sspatil@android.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, adobriyan@gmail.com,
	avagin@openvz.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, kernel-team@android.com, dancol@google.com
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
Message-ID: <20190203062114.GC235465@google.com>
References: <20190121011049.160505-1-sspatil@android.com>
 <20190128161509.5085cacf939463f1c22e0550@linux-foundation.org>
 <b15205cd-33e3-6cac-b6a4-65266be7a9c8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b15205cd-33e3-6cac-b6a4-65266be7a9c8@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 04:52:21PM +0100, Vlastimil Babka wrote:
> On 1/29/19 1:15 AM, Andrew Morton wrote:
> > On Sun, 20 Jan 2019 17:10:49 -0800 Sandeep Patil <sspatil@android.com> wrote:
> > 
> >> The 'pss_locked' field of smaps_rollup was being calculated incorrectly
> >> as it accumulated the current pss everytime a locked VMA was found.
> >> 
> >> Fix that by making sure we record the current pss value before each VMA
> >> is walked. So, we can only add the delta if the VMA was found to be
> >> VM_LOCKED.
> >> 
> >> ...
> >>
> >> --- a/fs/proc/task_mmu.c
> >> +++ b/fs/proc/task_mmu.c
> >> @@ -709,6 +709,7 @@ static void smap_gather_stats(struct vm_area_struct *vma,
> >>  #endif
> >>  		.mm = vma->vm_mm,
> >>  	};
> >> +	unsigned long pss;
> >>  
> >>  	smaps_walk.private = mss;
> >>  
> >> @@ -737,11 +738,12 @@ static void smap_gather_stats(struct vm_area_struct *vma,
> >>  		}
> >>  	}
> >>  #endif
> >> -
> >> +	/* record current pss so we can calculate the delta after page walk */
> >> +	pss = mss->pss;
> >>  	/* mmap_sem is held in m_start */
> >>  	walk_page_vma(vma, &smaps_walk);
> >>  	if (vma->vm_flags & VM_LOCKED)
> >> -		mss->pss_locked += mss->pss;
> >> +		mss->pss_locked += mss->pss - pss;
> >>  }
> > 
> > This seems to be a rather obscure way of accumulating
> > mem_size_stats.pss_locked.  Wouldn't it make more sense to do this in
> > smaps_account(), wherever we increment mem_size_stats.pss?
> > 
> > It would be a tiny bit less efficient but I think that the code cleanup
> > justifies such a cost?
> 
> Yeah, Sandeep could you add 'bool locked' param to smaps_account() and check it
> there? We probably don't need the whole vma param yet.

Agree, I will send -v2 shortly.

- ssp

