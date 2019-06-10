Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2D11C468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:52:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B753920820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:52:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ap3P9Rv1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B753920820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4790D6B0010; Mon, 10 Jun 2019 01:52:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4297A6B0269; Mon, 10 Jun 2019 01:52:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318AD6B026A; Mon, 10 Jun 2019 01:52:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA44F6B0010
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:52:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t64so4482503pgt.8
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 22:52:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=yYBt1hcQRQ0spSrpHXNNQXBu1ZghSIdq4bfDYf+JhQs=;
        b=ERKpOeNqjTz+d3Q2fYWMdWr7rlvcmW7xGRBDIeDeCCVbWJj2a/+ja60kzyybvl9q/C
         iKZEM9qjcFeZ8/Bxm3kcb9l7CgSbTiImGYfLcaAQO2Hd5ErlzAVPyhjWBjKAlkPTGDeh
         UZn0nOVS4pW30ct43An50sqrC/a0ImDHP5KWS7ZoQ8uSErY791z+AcDML/QvBWqetQyN
         lnEPSdnrRrnPlh5n2yzGzdsY583jQqx4TUj0vM3gpAEZttnkJXa3oyQdVpwwOwVyfOsu
         v01rr3eFHbB2BQlksaXzGCy9rEL/4GU3AwDr3YWSbXBzQwBJvIZljkAs9XU1AiguDd2C
         P38Q==
X-Gm-Message-State: APjAAAWeZOLsbGs0CiwM9Ry8639pxxp/TDKEap5oU1Eyk470LFhoztT1
	h45IzsFmSXXiBBo4ol5AfBa1N8x7Qx19KUDgpjUxGC+nOPE+kDjLbzukMcjbTZ4VP7aoY2dICZL
	0AR127ANmRTrrRcCvmwPvUWHMIEs5LEdOU025yNQWZMzTi0/voHek6eFf3TCaZaJmXw==
X-Received: by 2002:a17:90a:d16:: with SMTP id t22mr19774090pja.130.1560145931572;
        Sun, 09 Jun 2019 22:52:11 -0700 (PDT)
X-Received: by 2002:a17:90a:d16:: with SMTP id t22mr19774055pja.130.1560145930924;
        Sun, 09 Jun 2019 22:52:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560145930; cv=none;
        d=google.com; s=arc-20160816;
        b=tmUJOmAMug2KeeXyUIK+gjVVCHw3bojoKLGDAzxgeXsCj9UIeZcHcLVsQC/yhMxeRA
         W/r/FkCBWh2disEdlJ1+7HY3nFydKc6bV7eqxvbpgqk6mOb6YFJT/MN3k+/CPKwP/ysO
         g+2lEPPorWpqK3LSIh2mRhk0M6lP86QQAY4PAveNVlkwtrlREFERFWBWhdSyTvHqb909
         H1NQmqmzjb46DX3cZYw89iMae2uxKcqLP/iNKpZmCoXJRxTK/3rclEAcj/20jBEsjoG+
         qF6Hk/p7/9r0vHqdzA91zkW+pahP5pC5QbbwTiunQi83XPn4K2w+0GekMob5kUuVcaX8
         +3Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=yYBt1hcQRQ0spSrpHXNNQXBu1ZghSIdq4bfDYf+JhQs=;
        b=AH2N6WOT3Cm7JclSQFScGAAHMJbCSl836y3hhxEEMvDnsn7KvPeVLswhPOCtrEb+5P
         wL6n9Id/08ofLLRpxz/M8oLM9Il7BUnHmDvZDl8x7huUoKnK1yigNbahoELUiniCcZSK
         FWiWNyE6x4VwL52RPJknIF3XVi0WZ78BwuHTHGT7VtfH+2KSpvTHrpuxAkZiPzhZfeJd
         Vfr+p1/NsC+98SQQclrK+EatJF/QWpX1vf4iKrPoG2gmixYu1OIpIu8SjKD4WJ6LTJtw
         SLvxWlw0YtFDhgAUJVf90kZMxYrHQJ6nwGcYKKX33I8VhGPSP1K3QiyLwKTdlaBiJjsQ
         m+hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ap3P9Rv1;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w2sor10601640ply.72.2019.06.09.22.52.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 22:52:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ap3P9Rv1;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=yYBt1hcQRQ0spSrpHXNNQXBu1ZghSIdq4bfDYf+JhQs=;
        b=ap3P9Rv1D8aQHfClkdMrAIz0lJEB90foHbKNELFbvjYgglPGaYhZZDEGactmqxDbB3
         i+m5J8ngAGhJZb11iW+5E/vyO7uT254K24ZGbAxYTF7kz8oo6GsGkNjAKS++f130U4UR
         UUbpTGlCkup21/YPprv1FmY2NFCj/Zkl1wv0sV69bIiM8DgpcagIQO+vQGgQO8/2r7AN
         ZcZYFC0bQfmpDEP9Hc9VA/8BQKHEy9UviztpTRgHAfrNzLiuj0WS59rfT1892jQBYNk6
         /Xn43QCihdD3QMiH3u0Xv0VsizSFc1kAVU0z5uCFs1IvO2bJKtZnzNfvUepQZoQDkA0i
         Xa+Q==
X-Google-Smtp-Source: APXvYqwEoxXM5FQzuBBvwT6FbXqtViBTtkOAbbFjME16dv8NldZlQjn3iDQ3dOMqqHq0nrc6FYbq4Q==
X-Received: by 2002:a17:902:2983:: with SMTP id h3mr24952866plb.45.1560145930521;
        Sun, 09 Jun 2019 22:52:10 -0700 (PDT)
Received: from localhost (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id k1sm8446233pjp.2.2019.06.09.22.52.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 22:52:09 -0700 (PDT)
Date: Mon, 10 Jun 2019 15:49:48 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<20190610043838.27916-4-npiggin@gmail.com>
In-Reply-To: <20190610043838.27916-4-npiggin@gmail.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560145722.obq2bpepl8.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000008, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Nicholas Piggin's on June 10, 2019 2:38 pm:
> +static int vmap_hpages_range(unsigned long start, unsigned long end,
> +			   pgprot_t prot, struct page **pages,
> +			   unsigned int page_shift)
> +{
> +	BUG_ON(page_shift !=3D PAGE_SIZE);
> +	return vmap_pages_range(start, end, prot, pages);
> +}

That's a false positive BUG_ON for !HUGE_VMAP configs. I'll fix that
and repost after a round of feedback.

Thanks,
Nick

=

