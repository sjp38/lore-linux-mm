Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54DC4C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 13:30:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFDE9222DF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 13:30:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="AAqBWSkz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFDE9222DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DBD28E0002; Thu, 14 Feb 2019 08:30:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 489968E0001; Thu, 14 Feb 2019 08:30:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32C558E0002; Thu, 14 Feb 2019 08:30:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E16AA8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:30:10 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v16so4298061plo.17
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:30:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cD8gOqInkhDXw2CiDZ0G3aAu7ObyRZomWCuhX6uppCY=;
        b=QTpJxugB3Pm/1pQgUr+JpTGK2cIm3bQCTHgKKvvJoKKH9v6lhPDUCCycd9Of6zvBY9
         i5rIqsywJn3qz31qTqu3TZW1cTEuBAnOQukeWflT4XEdexUb7peY5bw+sFoRiRv4Nhb1
         FX3KDLUF25M6GKfPR6xq2e2Ry9FxnPBf2MePcouWXOVbUpH5MyGBtTkfR6J8P7n/qNoW
         ZPVOqYWRP+H5BKKdRC1Qlo2WxWRixPr9XhfzNf22rIKGLjz9Eqs1Eu5Fpc4p80SHDoy3
         jkluUg70xe+CjsJ45NEHQT4Vn2S4exzrY53qTsjQcGbseC/jY8AArKABPoNQbQfuu2Xk
         gG5w==
X-Gm-Message-State: AHQUAuadlGoR8TUdXzaVw9oNJ6er22CZBZExh+WsIFT58SgvL7jRTHx5
	sHemr2kbIxI+I3f+yyShNjWK1nLMvEc8PSKlaq2L9hIRRwMqaIUmlofWKiqyboGRNDanPQlyvJ+
	eBPhcDHDgx1HqZr0zbumC+Oqsl93ugTcv4SseLYZkYZcLxW4dQjTjhpzm5lCUN77V5ITjkiB92e
	2ljQD19sA2/L0iu2lOePXoOtl0ZZzyYVGAjcnXIpEWlsQY3AwWSNrpIIv97OsZEmQ1NVT/MAQCf
	/D2XrZTBBsk3vDkvzECmnRExSaWPWjJaC1uijsPjYaQ9ndZNBT+lJII9YsPkD/yV6CWQ8IEdRtZ
	O1E9+OfJz+J1QaQf0T+B1iV+6MFKIOr6O6NF1n8QZshAo4mKbD9IqE7HExWDs436olVWCdRvwrV
	o
X-Received: by 2002:a63:580f:: with SMTP id m15mr3823062pgb.342.1550151010481;
        Thu, 14 Feb 2019 05:30:10 -0800 (PST)
X-Received: by 2002:a63:580f:: with SMTP id m15mr3822975pgb.342.1550151009415;
        Thu, 14 Feb 2019 05:30:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550151009; cv=none;
        d=google.com; s=arc-20160816;
        b=O/TTcI7hEokbcShn83f+uiu9vlrGEGe6+BCQL3OMeFI6bGMBd1SDXqg0deeZeMtCY4
         mOrMXrF/NBhtGt4HXTw8RM5q+J3uaSA89n6J8ibPtAhqwv8sRMTykB54FplQU7T8f66J
         1iH8w0wV68+5HT4QRiMzMhEoa1/NsVlmjrzyeJ9Z5OfMwR+I8Ns9c8XYxGLvd5nrk8rI
         oUY+k7Z+7+iLX3cd2qLn3G4OUa0C7XJNfEi7zn+wN2UrhWcrv7lFiWr9G74McsxAAmKt
         kqYwY/f6SWzvD2R+QAyBmbws0I8bgZE93OWqB2ieDXfu3ULJHM/uYjdqXeZAsBHzi5+l
         rDXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cD8gOqInkhDXw2CiDZ0G3aAu7ObyRZomWCuhX6uppCY=;
        b=JmGk4woY6ID/JcCrfLtdngE1FpXECvlooe6iLCm34j1AkyDuw8xivIhMEZm+2GjnnP
         rO8Fdp+kqczWsGlfT/9ZND4hqrF5jhshRmzpn/hYxOJ5ifl2QtFlM0BYyS8BbY0dpruE
         +DkyUwPEbjyS/McVKD6yrZwHdRNeOZn6iJ4haqN/qZa5LBXAIHLeFIOet7B/4/mfjbfU
         +KLfNG/81nxNRSKzSW4njaGgaZhsmYRlsamWSZcCeyOCMedvrZGF4c3+6GDkgr7dWGg1
         CTEhIvkQyYFLw9DzBNg3vjcJjsoQpLF7hJiukXjwEu/OIBoG543iwyMcCcv6fdA4fP5N
         r8kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=AAqBWSkz;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z13sor3589971pgp.62.2019.02.14.05.30.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 05:30:09 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=AAqBWSkz;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cD8gOqInkhDXw2CiDZ0G3aAu7ObyRZomWCuhX6uppCY=;
        b=AAqBWSkzqbVNJ1NwR/lYh74r3OF7SADwVijueSwhv3pgXkJocI84Eg/PvjryagJ1Be
         Mp+DDGujpphUExEXT8wa264ko9phe+Xh2x/qeyOKZYywFpPBFJalsOvwpIFJf8QvCD+l
         rXNyN9CVyu9cIgKcgg931ZBrKFfAoFqJfAS/mkSnD+1nk3OWYjoKsIcqSOum/wOXngAw
         w9Obx4wIrgsr6cuYDKYwznchICuloxA0CLPEO+sVGn3doOBvaXoESv0sCz6adPpJJICn
         X+zEJ/lM+WTpDUvysNb/EpdBke7AXzosr+F2r5PmlSRWaLAelHT7MBAH55zTzBFxA5ob
         4jwg==
X-Google-Smtp-Source: AHgI3Ib8FcTyXhejuuqak93lu0VkvS65lcJUVtOIXNavlw5FG8HPeLMO12TkhRcqS2v6FeG68QNZWw==
X-Received: by 2002:a63:5b1f:: with SMTP id p31mr3818511pgb.56.1550151008763;
        Thu, 14 Feb 2019 05:30:08 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.44])
        by smtp.gmail.com with ESMTPSA id h128sm2825694pgc.15.2019.02.14.05.30.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 05:30:07 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 1A1473008A8; Thu, 14 Feb 2019 16:30:04 +0300 (+03)
Date: Thu, 14 Feb 2019 16:30:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212183454.26062-1-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:34:54AM -0800, Matthew Wilcox wrote:
> Transparent Huge Pages are currently stored in i_pages as pointers to
> consecutive subpages.  This patch changes that to storing consecutive
> pointers to the head page in preparation for storing huge pages more
> efficiently in i_pages.
> 
> Large parts of this are "inspired" by Kirill's patch
> https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux.intel.com/
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>

I believe I found few missing pieces:

 - page_cache_delete_batch() will blow up on

			VM_BUG_ON_PAGE(page->index + HPAGE_PMD_NR - tail_pages
					!= pvec->pages[i]->index, page);

 - migrate_page_move_mapping() has to be converted too.

The rest *looks* fine to me. But it needs a lot of testing.

-- 
 Kirill A. Shutemov

