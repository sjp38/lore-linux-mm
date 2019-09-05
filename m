Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20761C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3E4D20828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:54:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3E4D20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 584F76B0278; Thu,  5 Sep 2019 12:54:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 535FB6B0279; Thu,  5 Sep 2019 12:54:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 424AB6B027A; Thu,  5 Sep 2019 12:54:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id 213286B0278
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 12:54:57 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AF6D010E2
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:54:56 +0000 (UTC)
X-FDA: 75901466592.13.rake09_483aa12b7b03e
X-HE-Tag: rake09_483aa12b7b03e
X-Filterd-Recvd-Size: 3892
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:54:56 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id 201so2740654qkd.13
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 09:54:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=jE6ZC79bO1bFrMB62KwN7ZpncSaTigWMUVJvTrnSnEw=;
        b=FKcbWbsXk7qbUz+JoSMf2vUuDd2rSJ8FqDUvxiGW5r0Q9PZwxi5Zi+fikZxsOEMZBG
         5vmP3us/yt368p7dH9ux3oqBDB40n6+4FKeP01k0YsiyCxCJFfylaeOHva3e1cBmE2HY
         1hmYwTKRMPHN+YmumH3ZG+zi21l1egwq0q0FSsTtIUxWqFQLYTXCjrlSaRj1eebXoHyg
         13IYhhqDJFoxqP1P20SSynXES0v32p3NZRwzEkdZQ4IZlckvkPB2NI2DZTCQUb4RfeS5
         BfErclFJnfWu94yCUJxkiw5wuVfLFyvmdghV4MaF9gGTRwERQ8bg/Elfx0hrR+GEsM0T
         CKGQ==
X-Gm-Message-State: APjAAAWfDKc2QWWP9h5SeegejE5SNDu9pnhK6Ppxjp6oPg6uoI0E9zzM
	CKxvuZv65WT+a2w6o9D9Gq75hJee
X-Google-Smtp-Source: APXvYqwfLOIHZyQ8iOjDluAk4+y+6lFXCmFhYZR1/22lWMsqrGXka5bWbv19wHUkbOT8953e4sY3ag==
X-Received: by 2002:a37:7686:: with SMTP id r128mr3835153qkc.444.1567702495838;
        Thu, 05 Sep 2019 09:54:55 -0700 (PDT)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:500::2:4832])
        by smtp.gmail.com with ESMTPSA id r19sm1560936qte.63.2019.09.05.09.54.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Sep 2019 09:54:54 -0700 (PDT)
Date: Thu, 5 Sep 2019 12:54:52 -0400
From: Dennis Zhou <dennis@kernel.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] percpu: Use struct_size() helper
Message-ID: <20190905165452.GA41838@dennisz-mbp.dhcp.thefacebook.com>
References: <20190829190605.GA17425@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829190605.GA17425@embeddedor>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 02:06:05PM -0500, Gustavo A. R. Silva wrote:
> One of the more common cases of allocation size calculations is finding
> the size of a structure that has a zero-sized array at the end, along
> with memory for some number of elements for that array. For example:
> 
> struct pcpu_alloc_info {
> 	...
>         struct pcpu_group_info  groups[];
> };
> 
> Make use of the struct_size() helper instead of an open-coded version
> in order to avoid any potential type mistakes.
> 
> So, replace the following form:
> 
> sizeof(*ai) + nr_groups * sizeof(ai->groups[0])
> 
> with:
> 
> struct_size(ai, groups, nr_groups)
> 
> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>  mm/percpu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 7e2aa0305c27..7e06a1e58720 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2125,7 +2125,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
>  	void *ptr;
>  	int unit;
>  
> -	base_size = ALIGN(sizeof(*ai) + nr_groups * sizeof(ai->groups[0]),
> +	base_size = ALIGN(struct_size(ai, groups, nr_groups),
>  			  __alignof__(ai->groups[0].cpu_map[0]));
>  	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
>  
> -- 
> 2.23.0
> 
> 

Hi Gustavo,

Sorry about the delay, I meant to get to this before the holiday. I've
applied it to for-5.4.

Thanks,
Dennis

