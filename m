Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D7DAC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D2D9206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:13:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D2D9206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01A1B8E0004; Wed,  6 Mar 2019 18:13:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0CE18E0002; Wed,  6 Mar 2019 18:13:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E22DA8E0004; Wed,  6 Mar 2019 18:13:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D37C8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:13:54 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id w4so780107pgl.19
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:13:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5xicT+JC9oblTCrAdpVGLVFcJO/wB0p+Szv3OSBbjp8=;
        b=RWoq3io7d3eBnRGrQgdqfR+hvTGf6WFNcgi6rwOPw4WmMvUYUzC27BGZ/ojbFooGeC
         YTUdQ7vimTMbtp6Vkm1j/volQrpePMm0Cu4B+y/1qMw7g5t6lvW4NwWy8bWuJpwqlqh1
         z6kjtgiE2xqvjoC/0tfdayJcaJ8aX8dtZ8R7ngFtEtEgza7/GsEpnJPm2UPWf8fTI1LY
         lzfxzjdJJLMuZXszU0XuA15qGm27uUxS9udVcSn/lm6LU9tH1v44WKc6L/Whf8cxH0Qs
         8ITgFP6FC9ErCENa8aChijautfgBzkwx0BYSpqgMcV0qsY84ny903w/4iJhDLnTr7xGm
         xwSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWtZ5L3MFVUqVI/muzmySaljYnXvzlSIvhBUB6ecfP0nQ1lyIOW
	dD0ES/J0U2nhfmAoiHBTzQa+6LGUbR36Ltv1y7Nu50lvChroeFDkwzdB4BAcYI0s4O5F91Awrze
	ILGTuanugIUi6P58qO946QmcRSP1gdrUQFvMnubGo6AV5UjEBuaYTfNmzhzzih3LGWg==
X-Received: by 2002:a62:a504:: with SMTP id v4mr9885593pfm.22.1551914034289;
        Wed, 06 Mar 2019 15:13:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqwKAabx8OhqXvlH4XeX+5JCqkVKKBbHOkz6ueo4WX5nFHNuhzOfW4WRYJ/YPBvnM+jvyHUo
X-Received: by 2002:a62:a504:: with SMTP id v4mr9885527pfm.22.1551914033285;
        Wed, 06 Mar 2019 15:13:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551914033; cv=none;
        d=google.com; s=arc-20160816;
        b=xplYTviBs69+opzj5HxiVafx2EO3MpGYyyIoQHtcA/LPFYJZ1C6OR4Yq0jgQFypHM1
         toLBHQSftIlqhZ084i+jQ5w5XZa+qeQM5ZpA9FK+s4nWBc+BDp6w5+tfuYw7yryz1FPn
         7qfIiUW25YbcRk0lXGO6priut7z6yTV4mmwgTaKcmEt3A4SrFH48lNBD8Hv7vNHa9vwJ
         1uXVGDVReenLXwNJAK7mwWTcXjm0aVFm2Po33eRpQXNEu3c8RLl6ZidbNe5HSUmVwGpO
         cm/6QmSfXKIsPhaQi1SJNcKEaMvYAVJBzJ2MrfpnUgsJUlopimDr7mwtQ6INpOjwFZ+Y
         6bFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=5xicT+JC9oblTCrAdpVGLVFcJO/wB0p+Szv3OSBbjp8=;
        b=LSmbkaQ6+mwmnpnamQNbfG3ZjW1uu7p1kLSrRwFNK+vWp+h6z000R/FKASAgDbuzAl
         rDR+y7IikulkCV3OjIuDzmka4FhXB0AipGJnzagPpN8rFNLrbU96pZ0qyXmL+lIXbNm4
         nl9uHvrb+DZVxX+xhVxiMa9eNSqxXuaMFZyh+GXSjdiOsJ0LM6NUZNH1RU33JD/rRA/a
         7RIN9VD3lkxbKzUXyvMcqNH8H3Qs0qcm1uqEFamJlLL0msrbM2MQUwJ3gF1DBs8G1lrV
         20M65rt08l5y2n6zfpk1dQGWChIk0o2d17VxWGvSL+a1PSVPOfHppylE3TVSKEUnJXkp
         zvuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f23si2535162pgl.225.2019.03.06.15.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:13:53 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 836AFB664;
	Wed,  6 Mar 2019 23:13:52 +0000 (UTC)
Date: Wed, 6 Mar 2019 15:13:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Greg KH
 <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, Jiri Kosina
 <jkosina@suse.cz>, Dominique Martinet <asmadeus@codewreck.org>, Andy
 Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, Kevin
 Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, Cyril
 Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, "Kirill A . Shutemov"
 <kirill@shutemov.name>, Daniel Gruss <daniel@gruss.cc>, Jiri Kosina
 <jikos@kernel.org>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
Message-Id: <20190306151351.f8ae1acae51ccad1a3537284@linux-foundation.org>
In-Reply-To: <20190130124420.1834-2-vbabka@suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
	<20190130124420.1834-1-vbabka@suse.cz>
	<20190130124420.1834-2-vbabka@suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2019 13:44:18 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> From: Jiri Kosina <jkosina@suse.cz>
> 
> The semantics of what mincore() considers to be resident is not completely
> clear, but Linux has always (since 2.3.52, which is when mincore() was
> initially done) treated it as "page is available in page cache".
> 
> That's potentially a problem, as that [in]directly exposes meta-information
> about pagecache / memory mapping state even about memory not strictly belonging
> to the process executing the syscall, opening possibilities for sidechannel
> attacks.
> 
> Change the semantics of mincore() so that it only reveals pagecache information
> for non-anonymous mappings that belog to files that the calling process could
> (if it tried to) successfully open for writing.

"for writing" comes as a bit of a surprise.  Why not for reading?

Could we please explain the reasoning in the changelog and in the
(presently absent) comments which describe can_do_mincore()?

> @@ -189,8 +197,13 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>  	vma = find_vma(current->mm, addr);
>  	if (!vma || addr < vma->vm_start)
>  		return -ENOMEM;
> -	mincore_walk.mm = vma->vm_mm;
>  	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
> +	if (!can_do_mincore(vma)) {
> +		unsigned long pages = (end - addr) >> PAGE_SHIFT;

I'm not sure this is correct in all cases.   If

	addr = 4095
	vma->vm_end = 4096
	pages = 1000

then `end' is 4096 and `(end - addr) << PAGE_SHIFT' is zero, but it
should have been 1.

Please check?

A mincore test suite in tools/testing/selftests would be useful,
methinks.  To exercise such corner cases, check for future breakage,
etc.

> +		memset(vec, 1, pages);
> +		return pages;
> +	}
> +	mincore_walk.mm = vma->vm_mm;
>  	err = walk_page_range(addr, end, &mincore_walk);
>  	if (err < 0)
>  		return err;


