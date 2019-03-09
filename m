Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51FA0C43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 00:28:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2D5420851
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 00:28:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2D5420851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EFB68E0003; Fri,  8 Mar 2019 19:28:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79E0A8E0002; Fri,  8 Mar 2019 19:28:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68D0C8E0003; Fri,  8 Mar 2019 19:28:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBD98E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 19:28:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e46so10528861ede.9
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 16:28:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=u+1zttxnBRdfyUXn7V6A64I9IGw8AUgP86nQqjIrQE4=;
        b=F1ZBGdri5fI+1PuUejYPy0jER31ux2JcDJToIHb8+8lFZGhK1Lk9LRmDqbWQwU4CVc
         rcYgQb7Y3qH4laxhuNC1K6GcKsNMJvYr+AFE9f6COtDd3tVmIsLXe3Rz4Hup4DUILIJO
         7P0RIOy0nubPnw6OUrsIHucbzqzbLyYcwQRS4x7kbmLyY1gfWBvEBpMmJaIabolJiV+7
         a516q/7+QuThaX7v+AoLfyqAWEGSs9TZhtDganjcKfyhz/PI5zklWBequb+qoErAusvV
         EfCSMaOFZG1nbKZTGNkZZnls2S7dBEqcljkRxpQoPPdQczRD1zDTdXHRs7ADgZupdvtF
         zqIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXGinGWqpFCA+mpBw8N6C/G8ym8ZjNq/0hxQG73YCvQ4P8kqMq3
	KX23d9eJYkITH1uhw40IDEILYn5txn4kDip2sm+0i15PJrfxHmKpeqqI/jQruTt4K7WAjV0GQue
	1nKlYkeQHxLK8mayfh2L6MI0Rq2IWqc3UzuV/kyRl+/eGAq/mw2CPhIqaTdprAbh+SA==
X-Received: by 2002:a50:910c:: with SMTP id e12mr34138504eda.259.1552091324482;
        Fri, 08 Mar 2019 16:28:44 -0800 (PST)
X-Google-Smtp-Source: APXvYqyeXEfSF77gBxIPuhMWMVooxr52wUJC1ts1CKBmHdtfLKRKF++s7L9q4fLrTLTx8rEJfngo
X-Received: by 2002:a50:910c:: with SMTP id e12mr34138470eda.259.1552091323632;
        Fri, 08 Mar 2019 16:28:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552091323; cv=none;
        d=google.com; s=arc-20160816;
        b=VGA5U0vKkZfLiFxRpLZh9FDYEmN2uNz/oUwGNAQEYXtCsS9ui23EN1iGl0np8QM4FJ
         PM4VZME48miOVpiYffujmXMWW/ousC78Edv/vGnLkI2NME024ZwfCD7jocSRF9H9xGVa
         oR+9k3bSvtqkM0to5dfuMa4oTgEIJn7VbiPSYgqQfwy+vQAs9Rn+5fH5LNr7z22yv3Hd
         YDG0yGwMJW61bPSw2iEn2XNArkJNymtJD152fgpmYmWZ6kvWgIlVeXABOKmb5YeqLkDD
         AR/q3mn6lZXhzC16Ko6N+wHdT0bVjuDUTovUwncdu9MlV0xi0FIqBUm1LlNRK4amfoF2
         6C2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=u+1zttxnBRdfyUXn7V6A64I9IGw8AUgP86nQqjIrQE4=;
        b=lBiaN5Y/eh1+r1IVzWUElCsmeAneOsAhRSqBryXNTo0lNwUNTkKE0VGxFdDUR1GsG9
         9fznKoONlUAthnYU5zBU3VTiVhIxfQC3AZxJNsm3TAFuX2ucMDvmYPL1BLJpMwsRMsi9
         3zZTgpbltC0NCqkcgBsJ1DL8E+6lAv6u98B/7H0AzF5SpFwX1DZGzVmZR0itZpyrhzkk
         ezJb1p/VwT7MMd5rsF2uq7Eqjip7zpEDFQ7U6EdWKmTzXcgOheBkxBZfn4W1OT48Snhu
         qse1GDzYg7iHUht8qIcyWPUXmIyby2ExCXlcJvgScWU58zsfFi8+icKtx07pL1rARx/v
         OUKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id v17si2014650ejd.133.2019.03.08.16.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 16:28:43 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 2FA751C2B92
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 00:28:43 +0000 (GMT)
Received: (qmail 8266 invoked from network); 9 Mar 2019 00:28:43 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 9 Mar 2019 00:28:42 -0000
Date: Sat, 9 Mar 2019 00:28:41 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/compaction: fix an undefined behaviour
Message-ID: <20190309002841.GL9565@techsingularity.net>
References: <20190308224650.68955-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190308224650.68955-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 05:46:50PM -0500, Qian Cai wrote:
> In a low-memory situation, cc->fast_search_fail can keep increasing as
> it is unable to find an available page to isolate in
> fast_isolate_freepages(). As the result, it could trigger an error
> below, so just compare with the maximum bits can be shifted first.
> 
> UBSAN: Undefined behaviour in mm/compaction.c:1160:30
> shift exponent 64 is too large for 64-bit type 'unsigned long'
> CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
> W    L    5.0.0+ #17
> Call trace:
>  dump_backtrace+0x0/0x450
>  show_stack+0x20/0x2c
>  dump_stack+0xc8/0x14c
>  __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
>  compaction_alloc+0x2344/0x2484
>  unmap_and_move+0xdc/0x1dbc
>  migrate_pages+0x274/0x1310
>  compact_zone+0x26ec/0x43bc
>  kcompactd+0x15b8/0x1a24
>  kthread+0x374/0x390
>  ret_from_fork+0x10/0x18
> 
> Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

FWIW, I had seen the same message when trying to isolate potential
corruption (still unsuccessful, the tests always complete) but
considered it relatively benign and harmless. Still worth fixing so
thanks.

-- 
Mel Gorman
SUSE Labs

