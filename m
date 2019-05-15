Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6F7BC04AA7
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 04:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68C6620815
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 04:27:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68C6620815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7276B0005; Wed, 15 May 2019 00:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B40546B0006; Wed, 15 May 2019 00:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E13E6B0007; Wed, 15 May 2019 00:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9496B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 00:27:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so1838988edr.18
        for <linux-mm@kvack.org>; Tue, 14 May 2019 21:27:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SQPoLFFtn8UCv1Z1Nviv/8vDGIi3MGHYFE5v5AoGyB8=;
        b=DInLpAmngFbBljLSNTdCIBsE7RuvVhAdut0gXEYW7wvqdydswm+yLTGArALQyDSu78
         uaabTBqWG35rQBCaKWDejR5TxDVJ8VbpsGg8TUlYkjwbYnF88N31XC7Mrd8bXpKBQjYU
         hfGOcOzICMCG9qUelVbmAhF6J8IX+Q25KLJIHy4db0KSZ+hSUMYvY2I/BcmZLEiPeGKU
         6H/igM6HG8MSHbJhpw+pyHaz3bZIcIS0vW0lIOlBiA5u8/b1mMaEnrJQ9UiSpZJ2d4/p
         +xYanQ1YoBcnipP3e7HZpMduOievaU/6WNTHf78/zDJldKZoV/7+fHHuNY5dlOizNL1e
         MaKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVW7TvuLHmaQnrjYXB9qV5ireUS0bJktCmseh57FtNLj90ZoQz2
	0DvuiZ9JT7moAlaBOuBSjBnrJb/4YHVa3hPmwo2N0Bw69pbuWYbz6dEH8fWoU5SK8SQc+lvdccg
	0C3j2X9/ikllGuP1j0RFSw9EfKU+Tp7YMvHUspnqYFB6PtK1E6zCs9MxnURIFPGRjlQ==
X-Received: by 2002:a50:913d:: with SMTP id e58mr41203196eda.107.1557894427752;
        Tue, 14 May 2019 21:27:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykL98c8UXzfU8WXNZsQgw4xSQLqAIkQLfVrnEyW2HVUzh+9gZ2M/mAceTY8Du5fox3cK5c
X-Received: by 2002:a50:913d:: with SMTP id e58mr41203139eda.107.1557894426959;
        Tue, 14 May 2019 21:27:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557894426; cv=none;
        d=google.com; s=arc-20160816;
        b=sDVwD2Nn3V076faWk4dQPl01DUsJjyPrDNoSG8oEKMOW5FGFq8pW8WIoNqJau70AnD
         XjFp1Zb+VOeIsI+/evPZlUkd125NdJByBjHQqvI70H0OB4+/qqnA/r8EJHNF04hs19cm
         1t+eEydn4ZYe1xCqcOkskqxNUmYZYrh432b28qL7+EM39OuVwFT5bXNtTR1JwrkWkcbY
         RVb5AmxGwUi6VSciUU7IRQPAd84DdePzLuJ7memuHVBDz+F+ravUxEo5wn+k7+W44CPP
         OcxvMSs4fI4ogtgG285JoD/kGlB0U8LkfoUhLmyyq+BNmaWWMJ5oeJyFZh3VRRgsixPn
         DOLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SQPoLFFtn8UCv1Z1Nviv/8vDGIi3MGHYFE5v5AoGyB8=;
        b=HeuQx3e+oHZdzsynns1Igf1u0X2EFNFS0rVJc57wPMSswwnh4+CG7049kdg5ugIAiP
         Z4HZTIroVPuZgEpgc4LIF9gie6zjOtlmHTuhsNRJqxDlN9PhWLFGNdOXP0FthkbTVg5z
         QWE0v79m4xnbQh5BGqUeIY8bYNW+hvxPSDLg8O9rykn+9DhcH7V0MosNIV/eesqdfwbS
         X6sQutQCZRz0yojvz3OWZRFGIqpFPv51ndJHWw5/58TT7bvvoPPY5L3cR6vFS3u85jcF
         SNq4/GOCB1h3LJ9aQy04Xdhof9D1Y/7mayfFvjkK2Om+PbbX9Z9dPArVI7gPHHjx/uVu
         tjEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j15si619606ejz.123.2019.05.14.21.27.06
        for <linux-mm@kvack.org>;
        Tue, 14 May 2019 21:27:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A2DD2374;
	Tue, 14 May 2019 21:27:05 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 844E43F703;
	Tue, 14 May 2019 21:27:01 -0700 (PDT)
Subject: Re: [PATCH] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
To: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@infradead.org>,
 Vlastimil Babka <vbabka@suse.cz>
References: <20190514235111.2817276-1-guro@fb.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <78d9b650-4b47-60c5-4212-601c1719dba5@arm.com>
Date: Wed, 15 May 2019 09:57:11 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190514235111.2817276-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/15/2019 05:21 AM, Roman Gushchin wrote:
> __vunmap() calls find_vm_area() twice without an obvious reason:
> first directly to get the area pointer, second indirectly by calling
> vm_remove_mappings()->remove_vm_area(), which is again searching
> for the area.
> 
> To remove this redundancy, let's split remove_vm_area() into
> __remove_vm_area(struct vmap_area *), which performs the actual area
> removal, and remove_vm_area(const void *addr) wrapper, which can
> be used everywhere, where it has been used before. Let's pass
> a pointer to the vm_area instead of vm_struct to vm_remove_mappings(),
> so it can pass it to __remove_vm_area() and avoid the redundant area
> lookup.
> 
> On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
> of 4-pages vmalloc blocks.

Though results from  1000000 single page vmalloc blocks remain inconclusive,
4-page based vmalloc block's result shows improvement in the range of 5-10%.

