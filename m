Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AFF9C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E8AB216C8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:40:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vLjb1Kee"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E8AB216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2B816B0003; Thu, 25 Jul 2019 19:40:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DBEF6B0005; Thu, 25 Jul 2019 19:40:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CB408E0002; Thu, 25 Jul 2019 19:40:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 586586B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:40:02 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so31664090pgh.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:40:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eff2c+xz+9XiJe1zJ5JQ04Yg+8ikE3X8gugNUxpc1Uc=;
        b=tDZCD8An4oSQYnS2/mnpgzdhFgJmdQp4Kbd/yNXHj08CqQZQo1T4t6GllfLZn6DE8u
         i8ylGGTTVx2M6SuIOLbEfuwnZtvP9ZrDNArjUzXOsSz/rad8ylu9gkgDzRjc1hqZtZNX
         Irl/e1VcsLQ5uxr/n4gyOVCRJ1OC2Ydgomx8He+xvLfQZ3EleeYNiT1Ju363HmKMCpZ4
         lp2qdi6UZQLSkGQlX6GF275butzoH6NsQjLr+c7VZ803Ji5JlLJslkcDqQybR40JA3O5
         vldOi9ElabdeCY8oR/a1jPgAtyooMm3i00yOEZllEK2iOfoLhLeKaSclNymL23rIOPyc
         Ie+A==
X-Gm-Message-State: APjAAAVRP7Pwf08HDwFrEiGOXxjsWCF9LY4X7ck9sxnjAfQTfvpsfvYZ
	6r2JpdM4fXe+Q/AU19bB1e4HFT1bxh/dDCDATp5xW0kB17Fxb1oO+EQF8u2qZi7gHJil4QwUHpO
	Wl+gHU3EhqHwUWx4P+wj6gDnkCJwfPyRwOi+7cjqmp49O9JpJKeiyrEVofCGny68a1A==
X-Received: by 2002:a17:902:27a8:: with SMTP id d37mr93250359plb.150.1564098001919;
        Thu, 25 Jul 2019 16:40:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkKYcV9Ed+vMihnocUcFycpAcWRMIrgS7ohYarUGAzNENTGPi4wYhp/JEco/Gy/w4eWccI
X-Received: by 2002:a17:902:27a8:: with SMTP id d37mr93250317plb.150.1564098001293;
        Thu, 25 Jul 2019 16:40:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564098001; cv=none;
        d=google.com; s=arc-20160816;
        b=lDlaaAYn6G1mxqKKzqoBIPn1U3RfQHjXU/obhtn7BdG5gqkCWdvY7vXTrcamMWvPCa
         KW3sZhLF1Hp24PRQMGZCg722U4+9QGTWuAC+ewK9MtvjUzZC+JbjWSkx5ToAkB4ClXo4
         hg7eJzo4TmFjb1KMfR9yNtCnZrD+1TlBQ69uWBGBMzP5uCRcyUdS1que3gTYo8IxUl4N
         TqIewVs8x71yW5r+rlgAlrsu9c7drne9T878WdjS+HBTIlRMa3Ye49tL7ME1+7szeM8b
         onQBULZuHZj2w55fpSfEEDXcfa2V4rckDcVRyXNDARXiEratjKO38JYamKF79rUueSJR
         JlyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eff2c+xz+9XiJe1zJ5JQ04Yg+8ikE3X8gugNUxpc1Uc=;
        b=0ICSPT1JSw1Wlw/cS9Lp5Y9NzOr+t307HJGza+6FEnT+TtvzyxkHaWUUIm0Bisx+Md
         Zue9np3o7uENmV0yddpwJI+1pA4NjwqwFjPT+dU5eTONued1zXWHU1qQ1jyXtP1h9khH
         gmo/IkaNxyFqE5IbX+RVh7oBLLCPJ8oUJvYnsLYviajbMNFRiHQi0MHrVCLKuIRMdVlF
         q+3CvaQa2Xzq7ANzcUDcsgnBX3oMJf0jK74L/wVneaXP+t1P/kth3xotHkKulbkglMfG
         kWuWvO6gTYny2VW3qQTPCIM6F7BITujcTUTXsvKerTho6TpJVrzVUjwGPwQUHc3+fXal
         peSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vLjb1Kee;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x16si20781980pgi.312.2019.07.25.16.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 16:40:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vLjb1Kee;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6A2BA21951;
	Thu, 25 Jul 2019 23:40:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564098000;
	bh=iy1BW35mJIm+u1ndRp7gqExlXuNpjLDRAzH09BcEAsY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=vLjb1KeectGNjzRx+6eWqeYw0tAHPetlrJyW2cFRrGjB2oFd3tgLcRcumIgiMgdTZ
	 TMAykIuGqE3toftxZvn8UfWrN2Z1iib1K/EY1Kshp3irJMUwfFbRe3ciH4nWGJQxGr
	 D55fhfKMXurpk7OHLvUawEz9kGaz+yJdOp67nph8=
Date: Thu, 25 Jul 2019 16:39:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au, Chris Down <chris@chrisdown.name>
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
Message-Id: <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
In-Reply-To: <4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
	<4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jul 2019 15:02:59 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 7/24/19 9:40 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-07-24-21-39 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> > You will need quilt to apply these patches to the latest Linus release (5.x
> > or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > http://ozlabs.org/~akpm/mmotm/series
> > 
> 
> on i386:
> 
> ld: mm/memcontrol.o: in function `mem_cgroup_handle_over_high':
> memcontrol.c:(.text+0x6235): undefined reference to `__udivdi3'

Thanks.  This?

--- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix
+++ a/mm/memcontrol.c
@@ -2414,8 +2414,9 @@ void mem_cgroup_handle_over_high(void)
 	 */
 	clamped_high = max(high, 1UL);
 
-	overage = ((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT)
-		/ clamped_high;
+	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
+	do_div(overage, clamped_high);
+
 	penalty_jiffies = ((u64)overage * overage * HZ)
 		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
 
_

