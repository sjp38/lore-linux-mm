Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6451DC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:23:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F51A20843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:23:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F51A20843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2D5F6B0005; Wed, 15 May 2019 04:23:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADE636B0006; Wed, 15 May 2019 04:23:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95A416B0007; Wed, 15 May 2019 04:23:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD3D6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:23:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1so2657856edi.20
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:23:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E9OVjpGAL6fdshLValhZTEk2YlOabLMUHi2c27s91xU=;
        b=cOEneqAvnhC5BmweK5ClIYuSE3tQCs8e1jP4RvT13DVkfvFZ+lV+3N6OJeMrQPQBZ7
         Ff7hX+6kKCNb98u+Xvvsy6c4cJt/PkueyAVufQxsRFwvlk1gLXy9fIeVriSYddA2J89N
         bFyDizH7ypxE+WWlY93mBcOO/efmSNvd2pemqdfQ419aOjGB6kYw/aK7xfT7y835jieX
         y0GaL9nU3bKaqF1dX50NlVqWKIWlQOaKC8XNc0avcQS44ClgZ0OBnKu/f150vvFR/z6Y
         xq0TbXjbu/BLw1iSTkV064x7s96WXb4tayzUUVhb+BjgNJxW7p3Np69i4wesyv4ss3+V
         OoWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUt6T6mUiom7d8H8hKu8bWh4fhCVqALrOG0WpFjqCyeLZq10r5q
	avTI4g/9EaPOQpL4+/V41JfLFwi3uCYNQVYY26n+fSb3SVP40eHkCaRXL8Molm0po7S+5r7cGsY
	MkNssrnUvjLfjaQrmeujIjxdAfQs80GCTPS6qvXt4RNjI1dFHwT/0jdEhBD1Gkr9o8w==
X-Received: by 2002:a50:b6b2:: with SMTP id d47mr42458546ede.169.1557908614961;
        Wed, 15 May 2019 01:23:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqya9QmP+o0sZdpa+ydDmNLtRr635Ip9ec0QqYdwoavOp9kDqZ4VYU8Cutr8hRi4ow/4A4Tb
X-Received: by 2002:a50:b6b2:: with SMTP id d47mr42458497ede.169.1557908614323;
        Wed, 15 May 2019 01:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557908614; cv=none;
        d=google.com; s=arc-20160816;
        b=qReSHGIgkj2FAcUqVVo2Gkxp106iP5KhIN40S/Hqh34soJrX940kTp4QERfKtq3cPO
         M3TI/3oOf5K4JgTiFIpH5Q0T1csXibsG2dtZtSLHJWl0Fdn1sajdAX1GuFxmPicK0XiF
         uWmOscyd7S6m63+pZWp6q3A4K+QFqbrlY1QppC6L8kIOubFDIjClqG3gHR/1bzLyZteL
         ozGSUbqM39N60ivwe+PIpT4fnS7uElS1I11HQagyjocg2MwHSkkx3XUkkOGThjOuu5cc
         cpg3UyurKkZJC8VPxKF2HbAA76ag8gmMzuq5T+80LH5ehgz3vPsKa5gcgYzI6Q0EIptO
         K5gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E9OVjpGAL6fdshLValhZTEk2YlOabLMUHi2c27s91xU=;
        b=gwImseofV2sFSUHcdJSC64IOudfXlAiCzmhSjmZ3OIyMGq/9gOgTIZyYlXwR7qfd4m
         XKMqE+Jxq4sprHDx0O3GQn2hEk8he4EX6pTZ5kewrJY8YFCR4MXzziTlsPNc4ocBaXi6
         OT30hbQlKUFfP/j0eDVejjoBhAxptmXkh0R+4Tinfq+A/9DfD6gWdlMhcCOeeu8tjwEf
         GrTd8knTNsNCuhlFEXtAEs42527+HlQMpGJPrVIIC7jpXE4yKPQyaZivQhu+jdfIFhEv
         5l3U2JSuxnjJvQ/h9ePYHjYHmAYusTsG5FUQxojUCQX8iZSmjB92pVfgNaxfWaf5lAi7
         onlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si823104ejm.308.2019.05.15.01.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 01:23:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1ACCFAF74;
	Wed, 15 May 2019 08:23:33 +0000 (UTC)
Date: Wed, 15 May 2019 10:22:59 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, mkoutny@suse.com
Subject: Re: [PATCH] mm: fix protection of mm_struct fields in get_cmdline()
Message-ID: <20190515082222.GA21259@linux>
References: <155790813764.2995.13706842444028749629.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155790813764.2995.13706842444028749629.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 11:15:37AM +0300, Konstantin Khlebnikov wrote:
> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|
> end and env_start|end in mm_struct") related mm fields are protected with
> separate spinlock and mmap_sem held for read is not enough for protection.
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This was already addressed by [1]?

[1] https://patchwork.kernel.org/patch/10923003/

> ---
>  mm/util.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index e2e4f8c3fa12..540e7c157cf2 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -717,12 +717,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>  	if (!mm->arg_end)
>  		goto out_mm;	/* Shh! No looking before we're done */
>  
> -	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>  	arg_start = mm->arg_start;
>  	arg_end = mm->arg_end;
>  	env_start = mm->env_start;
>  	env_end = mm->env_end;
> -	up_read(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
>  
>  	len = arg_end - arg_start;
>  
> 

-- 
Oscar Salvador
SUSE L3

