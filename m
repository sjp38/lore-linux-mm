Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4FFC76186
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 04:36:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE32720828
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 04:36:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rCdaI5ow"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE32720828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22DF86B0003; Sat, 27 Jul 2019 00:36:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DEB38E0003; Sat, 27 Jul 2019 00:36:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CDE58E0002; Sat, 27 Jul 2019 00:36:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B55276B0003
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 00:36:34 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f16so26671011wrw.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 21:36:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fgu+GGVg1EZygpoH3s9DclHYrB/yjZrN74J1ygtmHDM=;
        b=Q3CvNEROQQupooCef6g8dpvJ3+nNSHdeDH5DGL5LJ6Tf5p+ebG6kUkzfDfAw4FpQEa
         Ij9nIVWFGKuzmZkWLEDmp+AHky1KXqR14usUCtrgitmyKRsqsRNiysSjsdfoRliTr7IA
         M40gD9tTSjkx1QWLI9UVCr8HcciM7/jme3XvBlU51BwUBnIB8yKhwQWbFyaOOptU1Zz0
         ZqHmJTsyEKRosSFWGy/jHCG+0XeZWdJaz2GWl4JY5PxzBHi7jeYmIYN3j3OIBqCkzqNl
         oTEpivIqh/ERI+kwhHxMv4Tf+kELKOvN0BcC5hyHHuwgBOn6tLd8Z79Y/1AgxCvr05eI
         Mhzg==
X-Gm-Message-State: APjAAAW4FDpugl+QNpk5cGwjRvjkTXZoIVfLOT3huvblskdEEsf1267M
	6CMym8pdAnhR3UhqF7VjCFVe+H2so/METDd+clWNdRAsBpNxZ4HIvF0BcGwEjA9wKQ0S81jD4rP
	Fc0q46iapvlwOsP6ZjO/pt3MCPgHToyu7ZOjRSSHbrWjNJWUU1ofnuS1J0zOCojkrYQ==
X-Received: by 2002:adf:de8e:: with SMTP id w14mr3819029wrl.79.1564202194212;
        Fri, 26 Jul 2019 21:36:34 -0700 (PDT)
X-Received: by 2002:adf:de8e:: with SMTP id w14mr3818955wrl.79.1564202193621;
        Fri, 26 Jul 2019 21:36:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564202193; cv=none;
        d=google.com; s=arc-20160816;
        b=kBDC48E4bHwI/E074xQzB1bP5TuwSFJD0Bbz9BtVlf1921qN4v/tgqVAXI0mMeAqiP
         Vfz+z24Sv2IU7Ifch1cAoyc1h/67z0hANJX1cRDqjBK0kzWZAhMCJNm/lEsBNxgF3ORQ
         VC8kscjXOiNZaELM0jCvVAKRHvcR6uClGLiEtL9d4JsbK5b4hsYx+wx8ILpsRp1P4unD
         I597lwXZOWI1rc799ozP4tOyMbxudGZJ0efDPIOcI7UTiJTX1NCv7vKPS6pR8v+kC43/
         zyD9mMhbTdOqMot/CbNgLDw4njRQXWc9QXlnhboMHqyQSejP7km3bADvMjFxJi8GSFWn
         2osg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fgu+GGVg1EZygpoH3s9DclHYrB/yjZrN74J1ygtmHDM=;
        b=A5BZGK8IbqooBZF19cwvBJr0TLNtoq8VjivkzVCwdtqRHNwRiGfwWZNCsV3R6ykX7o
         wtCvUxB6HOsClyZasMFmpZGZiUBqTAsU7sL1NmhGqYfHnz8e2YanubF0DhVIZxsoNcAb
         7s1YXjOMZueyHoJY4pqfS826Dy956uooWYTy1AvX8bLi00jzgDArE9t9Z07PstBcTun1
         oTYvTkJojQcuy8Rm8W1WWdeoHwW1uj+QQ+kwuKBW9WUNn0CLiF1LRuaocT9QcDpbDbuF
         EE7tWo1NWvez1nJ9qCSpSb92wgD/CmOYjnNqOQ7O3lGuGAlbcNruX+BAPa9myN5j6kbJ
         dMJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rCdaI5ow;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a14sor43199744wrp.9.2019.07.26.21.36.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 21:36:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rCdaI5ow;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fgu+GGVg1EZygpoH3s9DclHYrB/yjZrN74J1ygtmHDM=;
        b=rCdaI5ow4Gypn3RIkjHZYS/h7C40k7HDxGmk4PNXBdQyErnWDTj5cewNyXnH9m9Ibc
         KWgiqyGFfnJyAJxcfuXfIGHiSY4GAexpXh+1OhSaIo227T1Iu7jqhJRpueo4l3EfKiXX
         SoDKLDixvK8YmE9NPbZiTmSWtQvBcuc5m5pxS6/JCxZo5dP8SHEbyHjxlsiHnAbbeSCq
         DbjXiK7OAS2UkXQVMBvKp+5HZpL6ObcsyxE+0js4AzVPtRbP6meDeazRmXiuyRJEEIcB
         5ZQMwgtb0aFPAWSTUxMcMXHOC8RuOYyRhkNoblpDTMiEEbg//yDXpffEZQkU/SJ0BgI0
         lJeg==
X-Google-Smtp-Source: APXvYqzccEi33UZ//inmdDXND5H+3IHNcEku4M74cRWUS5+7SqqAECOVxFTsB3ZmO3bcUki1fk+CJg==
X-Received: by 2002:adf:de8e:: with SMTP id w14mr3818862wrl.79.1564202193019;
        Fri, 26 Jul 2019 21:36:33 -0700 (PDT)
Received: from archlinux-threadripper ([2a01:4f8:222:2f1b::2])
        by smtp.gmail.com with ESMTPSA id j33sm110096204wre.42.2019.07.26.21.36.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 21:36:32 -0700 (PDT)
Date: Fri, 26 Jul 2019 21:36:31 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, broonie@kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Chris Down <chris@chrisdown.name>
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
Message-ID: <20190727043631.GA125522@archlinux-threadripper>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
 <4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
 <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
 <20190727034205.GA10843@archlinux-threadripper>
 <20190726211952.757a63db5271d516faa7eaac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726211952.757a63db5271d516faa7eaac@linux-foundation.org>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 09:19:52PM -0700, Andrew Morton wrote:
> On Fri, 26 Jul 2019 20:42:05 -0700 Nathan Chancellor <natechancellor@gmail.com> wrote:
> 
> > > @@ -2414,8 +2414,9 @@ void mem_cgroup_handle_over_high(void)
> > >  	 */
> > >  	clamped_high = max(high, 1UL);
> > >  
> > > -	overage = ((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT)
> > > -		/ clamped_high;
> > > +	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> > > +	do_div(overage, clamped_high);
> > > +
> > >  	penalty_jiffies = ((u64)overage * overage * HZ)
> > >  		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
> > >  
> > > _
> > > 
> > 
> > This causes a build error on arm:
> > 
> 
> Ah.
> 
> It's rather unclear why that u64 cast is there anyway.  We're dealing
> with ulongs all over this code.  The below will suffice.

I was thinking the same thing.

> Chris, please take a look?
> 
> --- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix-fix
> +++ a/mm/memcontrol.c
> @@ -2415,7 +2415,7 @@ void mem_cgroup_handle_over_high(void)
>  	clamped_high = max(high, 1UL);
>  
>  	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> -	do_div(overage, clamped_high);
> +	overage /= clamped_high;
>  
>  	penalty_jiffies = ((u64)overage * overage * HZ)
>  		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
> _
> 

I assume this will get folded in with the original patch but for
completeness (multi_v7_defconfig + CONFIG_MEMCG):

Tested-by: Nathan Chancellor <natechancellor@gmail.com>

Thanks for the quick fix!

