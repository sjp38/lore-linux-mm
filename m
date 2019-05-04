Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D53DC43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 23:33:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A4F820449
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 23:33:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A4F820449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C3EA6B0003; Sat,  4 May 2019 19:33:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 774366B0006; Sat,  4 May 2019 19:33:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 663976B0007; Sat,  4 May 2019 19:33:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF8E6B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 19:33:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n52so7912222edd.2
        for <linux-mm@kvack.org>; Sat, 04 May 2019 16:33:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/4jy6Ah8uhpyhTex6IUjCE58tNTpIPtB5VLjkmLcW8w=;
        b=HwNberVMQ14OwMqLQep5zhPAPNkkHiMFcwBHdkb5DgulW24XL+b2HOF7DCqU3hNM9e
         aeziJltNTfZlh5QTQO1PPTo9tHGqRKwRsN3iwyL/ihi9rhj3C27VGGV5Z+LGfCyCTXT1
         aqFV+TlNlOe5X16v2VzOoLzM9NJuwX2bjMeY1XSlnwTlMb07fVgA5cK4i+qKRPrdw2SW
         T7sp+OM2AjJGS/0fUW9ITwFwT3QA1HKuB7VaJA+Nf9MSU+KL8hnPRuyse1mjurC3/z+U
         cnEo3K4Oy6joa8rZlLSmWEdjSmZpAdf2Ge7LIFMw8s/k7ZJDxTnwc8ehZf+qA8B4kmft
         veOA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXbroxI3kwvJ+qwwExzoNIXAu8Ort2lKlCZw7PCrwtD2E6Mix4i
	754In5to6hyTmRPBwHrc8l9sD7XYz5sutSNeIFHgseVbMHetb4By+7Rm3m90l2nyXojDp1wKJpH
	UxDPhyqvN7gM0L77nycteFkyl8vec0smFH84+6HPWw41M78QClt4DYLlzfTwk9Lk=
X-Received: by 2002:a50:cdd4:: with SMTP id h20mr17365109edj.114.1557012798770;
        Sat, 04 May 2019 16:33:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwBP0Jly4N97LIgx1j1lTITqugzRNxYbUM5XCs8SqHz6YCEmAvBoRtyD51vyup5zIO5uCQ
X-Received: by 2002:a50:cdd4:: with SMTP id h20mr17365048edj.114.1557012797609;
        Sat, 04 May 2019 16:33:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557012797; cv=none;
        d=google.com; s=arc-20160816;
        b=o2/4OiLVSVH6zgAhyHonLRueZC9Z6IgC/hsIOPo6PvtLAaTEF+lnJDyZIUH2e337r2
         pq2POyuoKUQkwtOvHJKZ1UhRRrxVuSUFyh9zMdh/fpaoAFMGaN58xE8p644TLFUaP9pf
         Ef9xemviQy76RYYQ38JFRtghFKFQEpLG607JmN7pQjCjca8t8k30fb9AZ/jYcy1T/coR
         I2bB/pZeULqL5AQPlU+Nv+Keg8F6QJK5+zSC4dioMEkLMzB9mirwoYWgf0CGWAlOldiN
         zCAyH4JgzwPNTw9bQva/uQaM+m3l2lsHiXyaNrK83hEt/24BWT5aBwKkQJ1/ZwvcEUwL
         CuMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/4jy6Ah8uhpyhTex6IUjCE58tNTpIPtB5VLjkmLcW8w=;
        b=Xnfj+4uyBIaAFrYElnZhsK2LZDh4jlDu2RqkGhhr2dz6acvz7pCd+xRTGDFb+pgDVh
         CLdZQpweGcWZZGUrNXSG1DgwzPLlOq/+Fe1wJeii8q2U8puEWOW+XJpUmLSUANSl9pnI
         SVaJrdtaMH6+XDS/fJGozpUeE7vpt4MRjpZZLCWWY5+gfKsTCYGQpnr44+PFRTuPoVa5
         bFdKNSVBlIzYaqDHAtSl4458RM6ZjwRV1kxT3Srw7WnG2HNOSE9chK7487tVdsZznRlI
         nhK+i0E01edpBD31Lc1rNEbEKgPU7KFntTE59zLEsD6pa9EAA71J/5oA80P7sh607dQI
         /OSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l6si332509eja.290.2019.05.04.16.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 May 2019 16:33:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0FF0BAEE3;
	Sat,  4 May 2019 23:33:17 +0000 (UTC)
Date: Sat, 4 May 2019 19:33:14 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] swap: ifdef struct vm_area_struct::swap_readahead_info
Message-ID: <20190504233314.GU29835@dhcp22.suse.cz>
References: <20190503190500.GA30589@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190503190500.GA30589@avx2>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 03-05-19 22:05:00, Alexey Dobriyan wrote:
> The field is only used in swap code.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  include/linux/mm_types.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -326,7 +326,9 @@ struct vm_area_struct {
>  	struct file * vm_file;		/* File we map to (can be NULL). */
>  	void * vm_private_data;		/* was vm_pte (shared mem) */
>  
> +#ifdef CONFIG_SWAP
>  	atomic_long_t swap_readahead_info;
> +#endif
>  #ifndef CONFIG_MMU
>  	struct vm_region *vm_region;	/* NOMMU mapping region */
>  #endif

-- 
Michal Hocko
SUSE Labs

