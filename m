Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE501C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 01:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 753EC218FC
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 01:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 753EC218FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AA4E6B0007; Thu, 21 Mar 2019 21:54:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15BC56B0008; Thu, 21 Mar 2019 21:54:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 072706B000A; Thu, 21 Mar 2019 21:54:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFB0C6B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 21:54:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j184so696399pgd.7
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 18:54:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NiLJVxi7wTZ95EAX9x6HxyZT7a9pIqkd9z3QZI63BgI=;
        b=sgMVk1fSzzdKPBijE+Y3t5p/DvO1UgvU1eNJEPuZAZvWuvDZ8su/i5kKoxCudqbcRb
         ncmC6WXgAlB6+Xev2uVwCa+Zkg7LxCS95McDbEcX+NeY9nmO1EpeHdFZmxEYOS6BrMPF
         3+/c0o/CN30s6yJqgcfMSvd1qmRowgXvJLdyYjCSt8wHZljgwa9iwXJ+8EqlJpXvSgQR
         DllWvCcSwt85yW/2fruPGySO2mfaFf6VSxGBNP6wjwhtSEhaHrKH0EJjuOfmOrLQBHRc
         HfGP+aCYlcvMe7QsS7jp+zFRFU05z7/xX3y6uIUaIvZE7V+a6TDS3TNp4NNVvwDvp7zF
         SfKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWAO64xag0h4JICgUow44GlyuAGQnSZhhB+CSra4z0fGVvmlvJM
	5Rl2QhUAdFvHNXjhwAorlThFc7JmHb3ZDcTUikC07Ayrw9JCHL7R/MGc3tWFGa4+RXzRAgIWsqm
	VwIpStC0Iv/jqq7oxI0lmv9FlVS/ikD33FYw1Iuc0kNi9YB63Z+sK/QIBSZByag2Kog==
X-Received: by 2002:a62:1ac3:: with SMTP id a186mr6518337pfa.48.1553219695528;
        Thu, 21 Mar 2019 18:54:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE+Z3ektOZRGqXsz0HRC9P6LbX4l0HxEHpf3KSskytKwZ3aRZB9N6/NEQY4vUyutvp7QA0
X-Received: by 2002:a62:1ac3:: with SMTP id a186mr6518272pfa.48.1553219694741;
        Thu, 21 Mar 2019 18:54:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553219694; cv=none;
        d=google.com; s=arc-20160816;
        b=QDD9A6jpQWV7471ctExZo2lc2mZjCdmmfUsy4oXYbK18oIp2iXGGT/q47KfbNqtq6T
         Y/r9qToJx2RWxUAjBtlOpeZDVQJrhmm/D35uAzCNdc6RV0PHdBMTpxL3hszITlnsnxZl
         o7SudOX/fdejURXWJuFYv2P7Ai4H6cx/WDzbTp4oDjyXQNrkAID13QVonFwHp7i4ArZF
         jbe9hQsp7hi0+G/AZZHsiWpbvZvfGSqUAQm64jAkTPEof/jZi2ajRwY/KDpmZANEcT9p
         JYJyqhilMblYt3vMR+vFBTo7NbDy230GD08CkIzA0j3iQCXcbjlXAGSWyfjZ9hozJCkD
         SFdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=NiLJVxi7wTZ95EAX9x6HxyZT7a9pIqkd9z3QZI63BgI=;
        b=Tg8RjajhZTLg1K4feupNdU9jzk3/0et0pbMTJsXvXbnaUN5CM6rUg76WlZRBFRMU17
         ksU6qboyWxbX01iqhlkyWwwYG2vLgUFEtGUrhWFG5UdIscuH3AohCvv3pCn7jAD+7iTn
         es9OBqsf+3irTPPjp6PVJB30VtgJ97Bp3DWnervpe5e7OCGALyuo7DOUw+IOAC/NUYYy
         ZyTUfrKlWgiCh7+0aUwWAHN9ewalufHJdzvPfEYv4Lq07LrsboAEJGUQy25z8Z7m6acN
         VBn6QJukJKW/I/ucsApGsBObvNPGnXPpxfoCqAj/Iqm1v7xgUXOEvoUK6KFEmfBZlM9A
         dk6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q12si5993996pli.428.2019.03.21.18.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 18:54:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 33DD4E48;
	Fri, 22 Mar 2019 01:54:54 +0000 (UTC)
Date: Thu, 21 Mar 2019 18:54:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
 linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com
Subject: Re: [PATCH 3/6] mm: memcontrol: replace node summing with
 memcg_page_state()
Message-Id: <20190321185453.6458679180e1e41893e7312b@linux-foundation.org>
In-Reply-To: <20190228163020.24100-4-hannes@cmpxchg.org>
References: <20190228163020.24100-1-hannes@cmpxchg.org>
	<20190228163020.24100-4-hannes@cmpxchg.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2019 11:30:17 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Instead of adding up the node counters, use memcg_page_state() to get
> the memcg state directly. This is a bit cheaper and more stream-lined.
> 
> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -746,10 +746,13 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
>  			unsigned int lru_mask)
>  {
>  	unsigned long nr = 0;
> -	int nid;
> +	enum lru_list lru;
>  
> -	for_each_node_state(nid, N_MEMORY)
> -		nr += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
> +	for_each_lru(lru) {
> +		if (!(BIT(lru) & lru_mask))
> +			continue;
> +		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
> +	}

Might be able to use for_each_set_bit(&lru_mnask) here, but it's much
of a muchness.

