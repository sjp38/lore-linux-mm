Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F7BC76190
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 04:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28BBA217F4
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 04:19:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Si3rLHGu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28BBA217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B5276B0003; Sat, 27 Jul 2019 00:19:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9659B8E0003; Sat, 27 Jul 2019 00:19:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8556B8E0002; Sat, 27 Jul 2019 00:19:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51D786B0003
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 00:19:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u1so34260138pgr.13
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 21:19:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ax3ie0hJEDMUzkIDVnZAwwhgfeKONJX0O2vxCj5aHuw=;
        b=Jew552p9K2LKHrCZyc/duIjMeW82L63Bi3ZMRTLk3bselvYk6NBRIGNYSo4ozQKaLf
         YsKsWBrGd9yyqX1Fw7nOytl5pzHtwfhaAKLX/qc7zIkxlPJpKl2eF/aZPN687gug84vK
         HNaM6fyW9enNZXat7SQMTtbiPuj1LBTJL7umjjY90vzVN0sq2Wbr4y/EvzJKK7zfjrkN
         Ww1gyc1fzgmCFCRAziV6kmGRefwgOLcQv/S3laALn4vy3t1uKffWuLOqhSsNug5ci1KC
         6491k2b3p4cWSdLrZ1z+VGQjMCPSfkDSdvnxM1xeADz8EURoKiUerpTyXvvOr3ZKKBjY
         U1Rw==
X-Gm-Message-State: APjAAAUMiHeWw6rHOz7AXPaSt/JdCcfIfebsSrE5WLGsnVdBgeJMkxGH
	HuDylNu8Q9G35DerPoQPRsbMC8WnIPM7dnCLFrBl92PnuPdmiw1QPgf8Iu/Lqd8yzlCILd6yncI
	y8P/tR8P+BvmFCs572e9EZMUyqNclTNYpvOZKaULhQyKCKUMNjRT26GuqXmF6xNbHpw==
X-Received: by 2002:a17:90a:7788:: with SMTP id v8mr72493943pjk.132.1564201194864;
        Fri, 26 Jul 2019 21:19:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMvvxzZfR8Q1WTq9B6iaWxzMsJDs+L80i0bmiw/dPoShhj6DK6rT1W+rFy9MQ2gZFGb1ko
X-Received: by 2002:a17:90a:7788:: with SMTP id v8mr72493915pjk.132.1564201194238;
        Fri, 26 Jul 2019 21:19:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564201194; cv=none;
        d=google.com; s=arc-20160816;
        b=DQM7a6O46reKFIkkMLDF5Fa8w3TVoAT9vqTCZzMfS6SM0O7hOreCXNFu/LVLSXYVdc
         FbMx4mMji612v/c8qm+QjlrEYwJMqvtSmv43HTdL1xyAdsvQ+Ly5Z++BMpNd4tW/FX6+
         HgA8WVzj3O/BrS+YzDTtP07ieBht7k//t8xfV/wskgtfvtvOYaQsr4aO4bJFp+Jes81y
         EnUcvk0+/CDJNni5cDbkxcg1l1TOwbYdiGV6Tn/g1sEQAVF8jUtr3Py1fb+qEt2UVMFC
         Z0ti2KL319ei1/0rAawwjLCLCs6/pNf02vtctV+QZnAtSM7wrct+SSCasUOSLvmHjlD2
         4JmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ax3ie0hJEDMUzkIDVnZAwwhgfeKONJX0O2vxCj5aHuw=;
        b=HLl59gNz+hi4Gu4IqEswIVucL5LAE2agTCsRCAdD8wonGTlXlclFWA88YyeTd3JH1M
         6RgOoVksNXVDVEM8suRDi9ykhRQsJqkCxguPoXRBgtv30KDutS0yt7J9HITLpo0tLFKE
         xMxqt35gnqLsoNrSBN5GFY6o0e0L2fFXOOylejLVYVGReajeestOKNZrK0z/eJX3Xv1G
         oIn0AsS7WrTm5PPY8xQSHgFPXwK2iH5qebsuvbGPpPdx9XuXzHD+3cWrYKBIreFw7RfX
         kLJLuWvNXQnQSdrpDZxFbaS1xh86kXCPGoILmCfUWNyMkZh4N6GILY+DmprTqDulTYZ/
         GsYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Si3rLHGu;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cd16si19625275plb.72.2019.07.26.21.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 21:19:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Si3rLHGu;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6BFC621655;
	Sat, 27 Jul 2019 04:19:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564201193;
	bh=DAXocKaUs1I+EIldbB+MJ8xtiUKnU9+bzAcB5Dh3rFs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Si3rLHGubhl6iymuccm1NkdFsEQBIOxwwChTh+VOxQjeEKLMD6KXlbpcwWzqXN0Jb
	 9/HjDN/WTfFyz4nf1qtrVFiYo5lWmnrKQMVK3fdu+ow+4wQ1uVPX8QznIHqd2yxR55
	 MdxNZsUXRhNLapWll898oFUQKk9o388JXNzK5uvI=
Date: Fri, 26 Jul 2019 21:19:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Nathan Chancellor <natechancellor@gmail.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au, Chris Down
 <chris@chrisdown.name>
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
Message-Id: <20190726211952.757a63db5271d516faa7eaac@linux-foundation.org>
In-Reply-To: <20190727034205.GA10843@archlinux-threadripper>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
	<4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
	<20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
	<20190727034205.GA10843@archlinux-threadripper>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jul 2019 20:42:05 -0700 Nathan Chancellor <natechancellor@gmail.com> wrote:

> > @@ -2414,8 +2414,9 @@ void mem_cgroup_handle_over_high(void)
> >  	 */
> >  	clamped_high = max(high, 1UL);
> >  
> > -	overage = ((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT)
> > -		/ clamped_high;
> > +	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> > +	do_div(overage, clamped_high);
> > +
> >  	penalty_jiffies = ((u64)overage * overage * HZ)
> >  		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
> >  
> > _
> > 
> 
> This causes a build error on arm:
> 

Ah.

It's rather unclear why that u64 cast is there anyway.  We're dealing
with ulongs all over this code.  The below will suffice.

Chris, please take a look?

--- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix-fix
+++ a/mm/memcontrol.c
@@ -2415,7 +2415,7 @@ void mem_cgroup_handle_over_high(void)
 	clamped_high = max(high, 1UL);
 
 	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
-	do_div(overage, clamped_high);
+	overage /= clamped_high;
 
 	penalty_jiffies = ((u64)overage * overage * HZ)
 		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
_

