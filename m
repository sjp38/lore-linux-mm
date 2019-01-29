Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88E65C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:15:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F4902175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:15:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F4902175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF5288E0003; Mon, 28 Jan 2019 19:15:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA49A8E0001; Mon, 28 Jan 2019 19:15:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBD588E0003; Mon, 28 Jan 2019 19:15:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB208E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:15:12 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l76so15428568pfg.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:15:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IIymXwiJd6Y47qGUpK0igusqjdws/UMu+lfIt8NzwM0=;
        b=KReJMv0Z6bJnRSweDYMPQejEBEce6VPKxoTz+PSM+EO+dLLFLP7S/WwLT6xfBBabEZ
         x7wQm/tO4QZLo5rb65BzWCE9bS7YSRWkWoCYB11/ZJEOCM5st4cUj/X34n3U/NZOq05i
         c1lfWWHgteVyyxUujnRIrzqFsv+yuwwpjX/7eLEU/xbwf70pqDllmJDtN/CKuj7wN7RB
         VZtOkllwY7MspbVrQGcnxuQBPXhVQyvtwSY2+OfnvC+9B+shUynSYAOYEM9mOvdjmeHo
         BXTdOKq2PgmQYR8qWuPfDkTcJMHOm7a6iE8tixOOahyCwD0fRLTnJoZNoMVAGvZuor1o
         eoiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukd9Ey7HSunt27O3pH7CV5f3wfsFZkPsKoa13aSRPwSN48kGoSU6
	D24Pk166VC3donfN6on1ULJstbPJM3YT187qJQuy+QVHnO4JvAF2idqHI9NTOAJGGZhfmZMU4x2
	YUujiYzkcACcJSC8Ku3463+p5ICj/7e5DJQhsqMgLryWf5Wei5MBAwNLWw/DWUivi8g==
X-Received: by 2002:a65:434d:: with SMTP id k13mr21834631pgq.269.1548720912232;
        Mon, 28 Jan 2019 16:15:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4P1FDjc9BtC6sgyZCCzxn5iZhQKJEQ+H/rPt80rwAT87mqh7MjHm7qthkkh/7masmq8uVU
X-Received: by 2002:a65:434d:: with SMTP id k13mr21834590pgq.269.1548720911504;
        Mon, 28 Jan 2019 16:15:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548720911; cv=none;
        d=google.com; s=arc-20160816;
        b=Xn3MOQ0faymaLAIMKqx3DqaLGmpPjv6qRlKNe0kMELxJ+SEl514tyk6VbhJia/ComQ
         seo0upyWgxQAR61atasHww8CwdibP5EODNn4r1LSotEj16FLD+4cYQHoChbU7V4i9dEX
         epe3DkNxZlCQNdgb4FcV1XVF8d3cFEZzD6K0owXPbGqj3J6bvklF3UhLxB9t7yRNEtxz
         dmkEq3/cwzkoWkrJQpYO7zkkf2mZqm7Aiu9lVJZiDXmE0MQBCFzMZPLWmcdhw75emro1
         C6iCuOUhJ4HcKTiJSbidxaCJREbDPbFDsttqFiCGd0gy/ujijLvMaIlVlb4EqfQFWwUd
         3Fqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=IIymXwiJd6Y47qGUpK0igusqjdws/UMu+lfIt8NzwM0=;
        b=S7Gpx/jCeyNfaYoXToEuA2oIOYit+YFjcwv/TOCBH2k1tDmUP0LHY/AReik+DU0c96
         2DE1xemWxM3x1CZaP6bVes1l3j31e2HLJRQa6rCMIsSHpf0wZb0A4pE63KZJLEaspIRC
         aEhxAsjxl985hSFffv4BB/6RYeJ8QKYNeXkEnb4CfB4OrcUUFshyR0LBFFcgkLN+OPkR
         3Uq+Mw+yf1zU0G/vbNFVLg8gUso0NBjvoIDF+iRlrWw9WaXn8CCNmDNjHBlToWF0KBUH
         HZtPxbR5XgeskC1ypPWcP46L4zx2WMNH+DufolURl8iqr3Y0n2ny75+K4BGXPL4QqBKo
         Mltg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r197si38581378pfr.192.2019.01.28.16.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:15:11 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CA9DD254A;
	Tue, 29 Jan 2019 00:15:10 +0000 (UTC)
Date: Mon, 28 Jan 2019 16:15:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Sandeep Patil <sspatil@android.com>
Cc: vbabka@suse.cz, adobriyan@gmail.com, avagin@openvz.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 kernel-team@android.com, dancol@google.com
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
Message-Id: <20190128161509.5085cacf939463f1c22e0550@linux-foundation.org>
In-Reply-To: <20190121011049.160505-1-sspatil@android.com>
References: <20190121011049.160505-1-sspatil@android.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Jan 2019 17:10:49 -0800 Sandeep Patil <sspatil@android.com> wrote:

> The 'pss_locked' field of smaps_rollup was being calculated incorrectly
> as it accumulated the current pss everytime a locked VMA was found.
> 
> Fix that by making sure we record the current pss value before each VMA
> is walked. So, we can only add the delta if the VMA was found to be
> VM_LOCKED.
> 
> ...
>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -709,6 +709,7 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>  #endif
>  		.mm = vma->vm_mm,
>  	};
> +	unsigned long pss;
>  
>  	smaps_walk.private = mss;
>  
> @@ -737,11 +738,12 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>  		}
>  	}
>  #endif
> -
> +	/* record current pss so we can calculate the delta after page walk */
> +	pss = mss->pss;
>  	/* mmap_sem is held in m_start */
>  	walk_page_vma(vma, &smaps_walk);
>  	if (vma->vm_flags & VM_LOCKED)
> -		mss->pss_locked += mss->pss;
> +		mss->pss_locked += mss->pss - pss;
>  }

This seems to be a rather obscure way of accumulating
mem_size_stats.pss_locked.  Wouldn't it make more sense to do this in
smaps_account(), wherever we increment mem_size_stats.pss?

It would be a tiny bit less efficient but I think that the code cleanup
justifies such a cost?

