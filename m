Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E58C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:19:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C435221726
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:19:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="V1ZTErJY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C435221726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41D196B0003; Wed, 26 Jun 2019 18:19:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CD148E0003; Wed, 26 Jun 2019 18:19:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E2AC8E0002; Wed, 26 Jun 2019 18:19:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECC056B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 18:19:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 3so91848pgc.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 15:19:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AA7VD3GFMZeqfLBtCt2S+A1uuyRledJjEUkiWQjsKCQ=;
        b=nrEBN0btoPhJkorcq8cKy9TFOesf1Ry1X5HRSyqeD0iKI4qy9wpecMv6bEtVuos046
         yF78fSuZn3HC1zpQKmfbPgHOgn80vZtvyoY5fQr4jvmYay0c/RiZr2BO+z8foq8NMCfm
         rHve2Ispyc3U+pbz016sEQBTPxf140KyPMGGHcLDgcj7Hgd9Jt3tCZttx9n2MOPshaDq
         elUlRGDgnzkkf86UO8VyPdgG+3UaYsXO6kLZO8CXc53yy5FFZQWW075rprzyBiSt5GKU
         aRUdIVjFYbPrCQo8Irs+7ooJbbK96PnX1XC+2OLQTpjOP5zWjNUN+CP5Vs80ASo4LUjJ
         5vPA==
X-Gm-Message-State: APjAAAX4r4fr5GVb5l028He7QFcWcYASNW1EzurHuZZeWeUNGxgt0KmV
	2JNpJCnwK0Nw630Sd/S9gvdXQIWXTo5QcfhK3J2aRe+YcaViC0MBlRztp50dkqx9aJpGND5Mbyh
	itCn5MVyRZWCPd8/IyOjuy9ZmMu4Vz+Z8BPIFacrpvLDUKaOKhtvpdrX91OHA91zeGw==
X-Received: by 2002:a17:902:8649:: with SMTP id y9mr418377plt.289.1561587590518;
        Wed, 26 Jun 2019 15:19:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIbBPYVOVzkduTZ1JnY7tnmF/vqSJUSnuxZQMpBUaN7uEnpcdVJtg1FoYHxmUADlsl72Fn
X-Received: by 2002:a17:902:8649:: with SMTP id y9mr418308plt.289.1561587589529;
        Wed, 26 Jun 2019 15:19:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561587589; cv=none;
        d=google.com; s=arc-20160816;
        b=IDPY+Ik5usg9wlP9WOZHBxMW2hypUcTFWIz8wndw4jpvkWSU57mHvipzFO1YTHp2lW
         8gfdcQc/aPXoP4YeZhtTxyO1coL79XjBL9fGDM74laqXLonkKVmcrkw2ZW/bsohjcvD6
         5xiL2qU0BW2CVqKw5lVN/CL6MZbBQ/NsZv/iVN6ZsnIPHjb3BR6hHIIkeEwzZXHY76fP
         jyXMpSGEXpr7D38sWo3IBcntw/l3s2AAkS1Wv0q/6jHaEwfGEPVcmiEgqtvW+UC+k7+P
         QwLW6Td6BaRo8UbgL+hDHo+w1WxguhJwraScjwJyaBMNop9TIHQ2G3vlPDVzlIzJhPJ9
         AXpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AA7VD3GFMZeqfLBtCt2S+A1uuyRledJjEUkiWQjsKCQ=;
        b=I8qA1m0pmfnxX8dwOt2de6AbTOobGTJb0SHdI255jE+TCkHxcnan4A0HgnHtD8MvWC
         MRYmuUu9czm7fx3zwE5GOocdcTE9RvwWCAjt1a9QeAiVdMFVf0SiVodde7AJHfi6fpzS
         fHUO7mT21Iay3tYUbPL9gL2aQ6m1DzDpGDAW/K8B6DMNxSnU5/Wc+yc2K2MkGDHGFs1O
         NVeItiGN46LkKfA2oDui96BqblelSaGFfOLuAQ+HaQpVnXAwSmo+pqavN7sAaqAUoXE9
         AzvJrP7DANW7WoCy2tfPxUTDXM+4tjECtLP0XebHRsObZN625DCEUxto+QRmbSva1g75
         PDsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=V1ZTErJY;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i1si394145pfr.203.2019.06.26.15.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 15:19:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=V1ZTErJY;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ACEA021726;
	Wed, 26 Jun 2019 22:19:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561587588;
	bh=c0Iw0Ggd13IhEyjRFOmXhUUD+YM28SRchuqexF9BCDs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=V1ZTErJYsXSbHJP97kMPg77KfzqzKFSQRjVBwxArrrzX5GFXc2Y8FpbCCuUInvq80
	 yiaB8ssnbYTQsX98vFBjmcWuZwptMqRo7OZtkVsvq8rOWDvi3FwUott3qtSVKLMzHj
	 Z2by6AwrxU6h+QRfLhzBh0IigMzTdm0MkXV5tO4o=
Date: Wed, 26 Jun 2019 15:19:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: semenzato@chromium.org
Cc: linux-mm@kvack.org, yuzhao@chromium.org, bgeffon@chromium.org,
 sonnyrao@chromium.org
Subject: Re: [PATCH 1/1] mm: smaps: split PSS into components
Message-Id: <20190626151947.9876bb0ed8b2953813bfa5c6@linux-foundation.org>
In-Reply-To: <20190626180429.174569-1-semenzato@chromium.org>
References: <20190626180429.174569-1-semenzato@chromium.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 11:04:29 -0700 semenzato@chromium.org wrote:

> From: Luigi Semenzato <semenzato@chromium.org>
> 
> Report separate components (anon, file, and shmem)
> for PSS in smaps_rollup.
> 
> This helps understand and tune the memory manager behavior
> in consumer devices, particularly mobile devices.  Many of
> them (e.g. chromebooks and Android-based devices) use zram
> for anon memory, and perform disk reads for discarded file
> pages.  The difference in latency is large (e.g. reading
> a single page from SSD is 30 times slower than decompressing
> a zram page on one popular device), thus it is useful to know
> how much of the PSS is anon vs. file.
> 
> This patch also removes a small code duplication in smaps_account,
> which would have gotten worse otherwise.
> 
> Also added missing entry for smaps_rollup in
> Documentation/filesystems/proc.txt.
> 
> ...
>
> -static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss)
> +static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
> +	bool rollup_mode)
>  {
>  	SEQ_PUT_DEC("Rss:            ", mss->resident);
>  	SEQ_PUT_DEC(" kB\nPss:            ", mss->pss >> PSS_SHIFT);
> +	if (rollup_mode) {
> +		/*
> +		 * These are meaningful only for smaps_rollup, otherwise two of
> +		 * them are zero, and the other one is the same as Pss.
> +		 */
> +		SEQ_PUT_DEC(" kB\nPss_Anon:       ",
> +			mss->pss_anon >> PSS_SHIFT);
> +		SEQ_PUT_DEC(" kB\nPss_File:       ",
> +			mss->pss_file >> PSS_SHIFT);
> +		SEQ_PUT_DEC(" kB\nPss_Shmem:      ",
> +			mss->pss_shmem >> PSS_SHIFT);
> +	}

Documentation/filesystems/proc.txt is rather incomplete.  It documents
/proc/PID/smaps (seems to be out of date) but doesn't describe the
fields in smaps_rollup.

Please update Documentation/ABI/testing/procfs-smaps_rollup and please
check that it's up-to-date while you're in there.


