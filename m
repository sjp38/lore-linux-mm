Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F977C10F0B
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 22:46:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20D182085B
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 22:46:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20D182085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84B048E0158; Sat, 23 Feb 2019 17:46:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FACF8E0157; Sat, 23 Feb 2019 17:46:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA1F8E0158; Sat, 23 Feb 2019 17:46:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43CC78E0157
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 17:46:30 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id j10so4196097ybh.5
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 14:46:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Foic8TLGpFEWQebCcc/J37yQ/BZX4rqLMDGduE61c7g=;
        b=F/M8TmtKEbYQmFIgZ8utrkAJyqsXo/3+pa6Sq8sO4YSH8VBr9jM0LbeYCv0hmxv+Ol
         5PvUxCEFUiGaQOGw3ygSujrA5wwCLUWGUX/SOgFE77xR/jYiVwIXef/YkSri5A/tgpQb
         +rJHbkOG4p6A1wcwbu7hW89XXcVEpYPvvHJtQ3s4SzWk7wfLIwSPbLGGhnhIlB+MmiLt
         Vmc+DmlOe0a4gYT+h79UBPD6Xu4084OhFqW497vtPY5+SiGvRoNKtz1Um8Jn15mygxAA
         uZmPvVtUIH+e+DA3sPHux8ZUKOFTlvFV9Wbdh9aNervlNiAR7Mbni8dq4Z/VauGP3A9c
         fnOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub/p4aVrAnX9bKzFfffYD6W4hp0cPUbRsKEADgxtz5Mq79MerDp
	zhmlpl0+jsfuv7q5VXJRuLOW8YdkcyY/QL8yxnWRLjeZyey26MsiDxLXbtv4DutCO1/ClLWjBB5
	C3y3ehlivxfezKV61rte64jWfUyefCWsF9QJuNvhIltHeQTV0uGYVwdIkIMS21eKWmCNHzFKmpD
	IRcCIKSd/GjlXYWyiXPLz6goRdxaAs7HAhNERpdv97mWlLVJ1nF+36GfbfA7xoIJmzdO6rgDiWc
	iFqIauw9NnjYl+nQINuI02L89/cxD5nfi1wMGW5CERr5sMIJ3iuebqqjxfhL+WQCYKQAWLMfncS
	aPnBdCnMTqoCDUMwC/GB4I+X6TU3CCA4y78wAEAc/JD7CpUv2MR5l8jcgTE879X7eVz/QVmDQQ=
	=
X-Received: by 2002:a25:fc1c:: with SMTP id v28mr8974262ybd.396.1550961989971;
        Sat, 23 Feb 2019 14:46:29 -0800 (PST)
X-Received: by 2002:a25:fc1c:: with SMTP id v28mr8974226ybd.396.1550961988797;
        Sat, 23 Feb 2019 14:46:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550961988; cv=none;
        d=google.com; s=arc-20160816;
        b=qbJWDyiRDNIkdGJTcJrYxfVGqxXPeeEZcoerwBWt93pz+X1Pq0Lj5gGsXMlHsnorf3
         MY63HUejIS8Hlu32MkEye8WGZlMdVQNd1tR3q8hKZHo6S+m4IwX997MAFwUVdaH79MRN
         mlY1yr3m9DP1A4H735D9+11DPmxoVV5ZlcXlOd1STQsh2Uv6VY0403w26If1U2vs1mzf
         xUIsTTdI5uunx53X1ZrlZb4e5nYPf3lGPl7F7kW+UFCGv+Io9n6A96Gn6IfNVac5Mjpj
         xwVlXVdrMrvsEDl7Pq0Cjdw7+jSCaARcpM8S9NHWsoIQlmHSb/T9qRemQPbejOVpvTeQ
         4cLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Foic8TLGpFEWQebCcc/J37yQ/BZX4rqLMDGduE61c7g=;
        b=iPRSSvZsBVIUlXF2s7qnYjND9Nv6hrmRBKrdRVfxu4dC9w5njaTDPveKe/XTfSRGzQ
         Z0e5QL22lm5oZgojK9LbUEw8fIs2+2oahW4KkhQuAMy82vaxaO/7YrgVlITDi5D+nL4m
         Yz/80JN3EnPwcPuEbPtB8oZQ0zKK3c6e89VE1Ppo7nzGFQ1swimhKR4CMHksLk6BCrYH
         StM+ozm7rHqepFZnT5drgGW5zIV7XiVxErFUqNuilcLm2FZ/109Dh61fAc2k0/F/LPBq
         22zfvshYyPzV5k4taSiAkdmM1IrgG4LaKShccjQhdlVJD1S3qSgxGLwLRRPd/pBN+sQ2
         Thtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 207sor1041338ywg.152.2019.02.23.14.46.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Feb 2019 14:46:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IalnwdiMYy/npy4mUQOjhhowUfA3rNcImsp8uJRMJKJHCa1qYIlBIJ5NPM2nYwvbE09sHL+qQ==
X-Received: by 2002:a81:7850:: with SMTP id t77mr8686724ywc.451.1550961988248;
        Sat, 23 Feb 2019 14:46:28 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:180::1:537c])
        by smtp.gmail.com with ESMTPSA id z77sm2156704ywz.91.2019.02.23.14.46.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 14:46:26 -0800 (PST)
Date: Sat, 23 Feb 2019 17:46:22 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "dennis@kernel.org" <dennis@kernel.org>,
	"tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [RFC] percpu: use nr_groups as check condition
Message-ID: <20190223224622.GA31069@dennisz-mbp.dhcp.thefacebook.com>
References: <20190220134353.24456-1-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220134353.24456-1-peng.fan@nxp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peng,

On Wed, Feb 20, 2019 at 01:32:55PM +0000, Peng Fan wrote:
> group_cnt array is defined with NR_CPUS entries, but normally
> nr_groups will not reach up to NR_CPUS. So there is no issue
> to the current code.
> 
> Checking other parts of pcpu_build_alloc_info, use nr_groups as
> check condition, so make it consistent to use 'group < nr_groups'
> as for loop check. In case we do have nr_groups equals with NR_CPUS,
> we could also avoid memory access out of bounds.
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
>  mm/percpu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index db86282fd024..c5c750781628 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2384,7 +2384,7 @@ static struct pcpu_alloc_info * __init pcpu_build_alloc_info(
>  	ai->atom_size = atom_size;
>  	ai->alloc_size = alloc_size;
>  
> -	for (group = 0, unit = 0; group_cnt[group]; group++) {
> +	for (group = 0, unit = 0; group < nr_groups; group++) {
>  		struct pcpu_group_info *gi = &ai->groups[group];
>  
>  		/*
> -- 
> 2.16.4
> 

This seems right to me. It is quite the edge case though. I've queued
this for 5.1.

Thanks,
Dennis

