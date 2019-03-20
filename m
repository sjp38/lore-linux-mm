Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29ADDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 23:06:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF75C218A5
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 23:06:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF75C218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 575FF6B0003; Wed, 20 Mar 2019 19:06:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FBDA6B0006; Wed, 20 Mar 2019 19:06:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C5DE6B0007; Wed, 20 Mar 2019 19:06:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBCA56B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 19:06:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 14so3950608pfh.10
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:06:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=QPh+YAxBFGSvL/KdozvY7LZ+gpMSLIpw5zeVkurBM2s=;
        b=EH+GctM4VzGvGA/IxUNp/5AfPlQt4Bve9Pp2ckzg6WVaPO7sofTjqzgl6Nqdhyem76
         1DQ2HW5iiUGTuMmVZN5QZ+8+HI/MBriFR2yOuAQJU1qQJz0j776CWsQ+VTZE5oGB72f1
         qTTyIe8NruB444dKxvn0Ga/ObgDNCAJHHPj8H+tESiHX4oy1/M9DzGhHKrT8r47rLdIn
         hdBRxKgl3ZppY/arQ6MsUOwFxL9Lxlnd4LACMD2sLq5s8kt2Y6K9cSWTOLETlrJWN25w
         M8BIEjXbRj95tuRaLstqCHWCdJB8h3WxPNwCKX1vKg7LDr4vgIMcNvEEaBn+H8x2q4oL
         B8iA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV3EohZ5RMH5/fIO1U+UQXL9XIUTYInmxWoNuKvLGveFWzqcO1W
	tOxXqnAVeENgpqWumuJusBUFezU9laooBR23cK9wCYOzgifUMY0LlF9kOXTY5yb4VV1m4lntGwq
	Gmjmdz8KWueFJDKc66+s8SRVKnZU0gals4OBydmLcD/gyH5dSiuJaGjc6fI8cqk3WNw==
X-Received: by 2002:a17:902:b181:: with SMTP id s1mr283764plr.321.1553123212552;
        Wed, 20 Mar 2019 16:06:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymdD/1wfJm4hXCnl++HTAmHZqwGpWgtdletWShEAD5yKnBZIf2hS8Z+rLcPhnYEHEQK8jg
X-Received: by 2002:a17:902:b181:: with SMTP id s1mr283691plr.321.1553123211686;
        Wed, 20 Mar 2019 16:06:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553123211; cv=none;
        d=google.com; s=arc-20160816;
        b=QN7v2mR4gRl/QJk1bFx2CcL09lzmwW6GyvLafhj9YxYPyq7CB9vkISP5as9SYjMn2z
         zPZTdUqLknkmBMsl3yqCNAo3FtoyuyduGMfM5PS68/Kz2VekHjZImCGWAkyyUVwfi//A
         DnWqsdOYhrquUNBwkJ7+wrJhdKzVh8GeVuAkLUsCKEFmbP/3gi2tNiB4hATIb19+mclO
         UqWtn8b7shhiUI+XqV+lbM5gazbTtTVtuhXcY8bEM4DTIOg19gpVWDa88XQtIEXq/2SK
         lzWnA9w0yJ3OjJwqL1duMmHD6Fs4m9uOYfCmQ2MK0ARsR1abAnhaxVWuDM1BdI/Lt49f
         u1vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QPh+YAxBFGSvL/KdozvY7LZ+gpMSLIpw5zeVkurBM2s=;
        b=gEseObqVT7IOBAj0qttcjQM7NpzqPsVV6tOfPWtEsU9MRNtTGbXFTLXWrat4r2zuBR
         qGhmCfYOxKlfNKJ/npC+9diXtUKVKshLMywcD10CgOv+XIxrvC01K0Gytf1bVomiUT7/
         hbsXJdJaIo1ttPcb2e+cJGr+u9lXQ9By5v5fuMQpf8MV6mR6+iFrhbJU8MYxeuEYV+II
         ZoWEL+uXiDL4BpxjTcnqH6BiR//DdfSSX4ouU338enEej7B9uUur3qw+Wz210u21laAT
         iVI4gdlssNhbRvemmGJuqZPhTFFQVdNcQHUjxU61DFfDOLkN0pFsP1bXGVkzkKFlBxkw
         boLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id q1si2957527pfb.68.2019.03.20.16.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 16:06:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04427;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TNEARE5_1553123205;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNEARE5_1553123205)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 21 Mar 2019 07:06:48 +0800
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
To: Andrew Morton <akpm@linux-foundation.org>,
 Souptick Joarder <jrdr.linux@gmail.com>
Cc: chrubis@suse.cz, Vlastimil Babka <vbabka@suse.cz>, kirill@shutemov.name,
 osalvador@suse.de, stable@vger.kernel.org, Linux-MM <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
 <CAFqt6zbqYyzVB3HbYXv19jo8=3hGC=XZAkwvE8PCVdLOKTeG1g@mail.gmail.com>
 <20190320151630.9c7c604a96f0a892c29befdc@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <e8077900-e2d2-681a-9a2e-9dd500e7c83c@linux.alibaba.com>
Date: Wed, 20 Mar 2019 16:06:44 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190320151630.9c7c604a96f0a892c29befdc@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/20/19 3:16 PM, Andrew Morton wrote:
> On Wed, 20 Mar 2019 11:23:03 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -447,6 +447,13 @@ static inline bool queue_pages_required(struct page *page,
>>>          return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
>>>   }
>>>
>>> +/*
>>> + * The queue_pages_pmd() may have three kind of return value.
>>> + * 1 - pages are placed on he right node or queued successfully.
>> Minor typo -> s/he/the ?
> Yes, that comment needs some help.  This?
>
> --- a/mm/mempolicy.c~mm-mempolicy-make-mbind-return-eio-when-mpol_mf_strict-is-specified-fix
> +++ a/mm/mempolicy.c
> @@ -429,9 +429,9 @@ static inline bool queue_pages_required(
>   }
>   
>   /*
> - * The queue_pages_pmd() may have three kind of return value.
> - * 1 - pages are placed on he right node or queued successfully.
> - * 0 - THP get split.
> + * queue_pages_pmd() has three possible return values:
> + * 1 - pages are placed on the right node or queued successfully.
> + * 0 - THP was split.
>    * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
>    *        page was already on a node that does not follow the policy.
>    */

It looks good to me. Thanks, Andrew.

Yang

> _

