Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B86CC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:29:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05E8F21B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:29:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="zMmXsWNa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05E8F21B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B364C8E0003; Thu, 14 Feb 2019 17:29:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABEE58E0001; Thu, 14 Feb 2019 17:29:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95FCF8E0003; Thu, 14 Feb 2019 17:29:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5378F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:29:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a5so2639798pfn.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:29:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NvjkFmreiSParKFafQcGiRdK5zDzo6y3sTnyvcFNMzU=;
        b=AHvmTOjXBBfj3yMb0bnoJjMbpYabFFDdCLlkdT/Yu5YHktB33ITeMpMcr7JyhAAR+e
         zT+Kt33+tQKb+bnI3sSzaIAw5GDg9GlqWhQPO4Izb2AWJkfMICM4WxwtUp6ErAkDb5Q4
         z77fl5lzdQorhCA/c6Ns9UtYhcB6qzlepNb2bKHV/6K4MyXZs/tjRAdkMoTTSUAoD//z
         QHtUw/HaFmVDQ06P4eGlr2VwgrnELmIP5gLcOO1Y14xSLmvsA/zP1mGuo5CzW3pKf2vs
         4eTua2Dbz1aaWaV7PK+RO8A6gC+P0PWPw894iZRNgMCIgxpXxE+w0PqQ1rFTAR5iNO5p
         IyMA==
X-Gm-Message-State: AHQUAuZ5RXq+bizlFWWx/z9fQb15Et/hRN6/r2X2Jc/ntZ5LCH7xg2Jy
	PmZYn+ZvAbt5/Ah/NkFqh8CxEd6AJ76QoONCSQYcbNbHMt/RvQJg4Amypmj9aXZ+TbeTqisTxl4
	fvjG8vgQS/KfBElGd5v1cPUTgsRUaZmeGkqQWd/EmjiJuxupLZs6sr25pBmyUUVsr94lXG8Lctd
	O6TDOJPMfs8itKEahZDYWxRB3Do0lJJf3YgbHNeCK8nxPh3pJ2NDXz5YMi7+pGc2bcOOXLAxlVN
	WTmFwcmIwpt8vGHYfhfQHByo+zxjccqzIxWRQpvAC+AVG7FL+yP+3YSJlapp13lh4O7hWwm7Yih
	XoAgQSwQrPa8zCagp8IbMKjO0u76zUvVsd1oj2YXUxVbUkWXrHiWUHV174GgXj/sz+cb9kksCNE
	S
X-Received: by 2002:aa7:838b:: with SMTP id u11mr6517025pfm.254.1550183390035;
        Thu, 14 Feb 2019 14:29:50 -0800 (PST)
X-Received: by 2002:aa7:838b:: with SMTP id u11mr6516986pfm.254.1550183389450;
        Thu, 14 Feb 2019 14:29:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550183389; cv=none;
        d=google.com; s=arc-20160816;
        b=Gx0HEZqfJAd/DBHukZEMbalIHwnVKygGjPAF7LsnQgup/eYlUrqPS1EYnzb37N0zsI
         4Zut38//2dI723/mdBCTBC2KioU5AIi6ABCWYKdSz/TQ80PQnXlkTdz/DS651ZUpbXoR
         wzJgjYcmpPziKVlEGWJrDkt0f4j9j2LXQJavO4U/K53E2lBVKQnFyQdmNt/augyJe3j1
         V7NMZGkcrtWHCpVjajilcymntoteOih60R387g32NgACNo9hSNr+NO+L7rBRKvWHEz6x
         IP89HoxeanYwQE63t84oxqjlfW03R0M3Ejr02puMda0H8ua6k6IgYmA0klcFnZj2iTKO
         ltNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NvjkFmreiSParKFafQcGiRdK5zDzo6y3sTnyvcFNMzU=;
        b=EQc/iS5Airo8Wn1MHaX++51CMv4bKvQZ3lOVqsElazLBPDbsHktxGIHuUmtJLoKWnr
         g1Sp5jh8dZ3vCZzyylynPhpqRnR+2dXD8ownFaDq1ZGVsuX4FfsVyCFyvZfkXbCrEumk
         Rm0S4f60growZymwlH48hOtoxYsMJQ9zwtiEB9m/olU3zcQSI5t61Zp2BVKJEoBk3gUl
         vj/Ey1uFsDnJozc+lkOESzVW7fj+QLSw/60kf+8doF84OZqAy+7ZNsUwtDyPwNDCb/n9
         bP3W6zBzN2Bj49hSH+femi2M9hkIZX9FZlNqTT1JVbTPH2F2yvr9Gn7GgQJ7IzNdu1wI
         QoIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zMmXsWNa;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor5843000plq.70.2019.02.14.14.29.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:29:49 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=zMmXsWNa;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NvjkFmreiSParKFafQcGiRdK5zDzo6y3sTnyvcFNMzU=;
        b=zMmXsWNaqFgtURCjoEYmlG9ZootJV5ETk7RClqRFNaN8UtvsHttKiTduUB2vRFLESU
         Irv8uNMRW39/Dt4ph9ebsvwqiek11zObnThfoX3rv9ZPb9vmkPWCpfV53nTW18dGR9On
         Vi0iJd7SX6A7bQ5zmpinCi7IZXHRVufYoUWYHI7cpK3R4scCSdUtlFJH98y5l/CDRtfg
         sn7DnsR8Gb2ZciO30zpSgCP6vnc4KosNxCn+DbhIK0angJilTkL5hmoRLTXPXjC1/KPX
         Uy8melJuZm8a6jnjud5Fv/KJfyUlcg9KVPdEXDUPKkxb3klzdSxmDy5Er2KOBNYHafdV
         uA9w==
X-Google-Smtp-Source: AHgI3IbRwfPTP/Y0Xv5KT7Y/ZfnHrmYGt49yZlShyrIq2MoJyVHHOX2q/yx+7hvTOo/tOTXaLI+zsA==
X-Received: by 2002:a17:902:108a:: with SMTP id c10mr6737872pla.131.1550183388999;
        Thu, 14 Feb 2019 14:29:48 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id i186sm6122051pfc.28.2019.02.14.14.29.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 14:29:48 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id E68993008A8; Fri, 15 Feb 2019 01:29:44 +0300 (+03)
Date: Fri, 15 Feb 2019 01:29:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214222944.74ipvbnvo2lvfgnr@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> On Tue, Feb 12, 2019 at 10:34:54AM -0800, Matthew Wilcox wrote:
> > Transparent Huge Pages are currently stored in i_pages as pointers to
> > consecutive subpages.  This patch changes that to storing consecutive
> > pointers to the head page in preparation for storing huge pages more
> > efficiently in i_pages.
> > 
> > Large parts of this are "inspired" by Kirill's patch
> > https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> > 
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> 
> I believe I found few missing pieces:
> 
>  - page_cache_delete_batch() will blow up on
> 
> 			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
> 					!= pvec->pages[i]->index, page);
> 
>  - migrate_page_move_mapping() has to be converted too.

Other missing pieces are memfd_wait_for_pins() and memfd_tag_pins()
We need to call page_mapcount() for tail pages there.

-- 
 Kirill A. Shutemov

