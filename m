Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84CBFC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3049B208CB
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:38:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ShVOA7PY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3049B208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 969116B0005; Tue, 25 Jun 2019 15:38:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 919A18E0003; Tue, 25 Jun 2019 15:38:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 808C28E0002; Tue, 25 Jun 2019 15:38:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 492726B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:38:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z10so12260715pgf.15
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 12:38:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Zm+xExJBLveAa0DN5YO863/tHrrTEPNBV4jQ46p4ifc=;
        b=MHeMtD6wwC35EXKbD7Z3Mf8TSqjWvmI249Qb4jjM165HWVl58SnBMAsSiNzcYubYoz
         gJmAryZkSdeEgGP17ZtpUXC+GB/tlq0L7KNifmesBuk/plNmrFJ1iEfK+4JreS/slp5K
         GIPaMzY3gQW4FNSfiTMHciMaUBwq+5fYIcVNMaKt1rqT8eZ66zDhMZnRrBTf6AlHo309
         HDjE/eST+gGgj89cWb2CyLROdgLgx826cytZLbZGFgI13GWlKUH9zv9SMplNrcuF8oe0
         R7qfeE8zuOlkqC4sVQ5cDAXZmqy6q9WgwLZr4T/vf1psKcUvK8qt5xL38gAm5m4fiImA
         RJnA==
X-Gm-Message-State: APjAAAWkdnVpBgYhsdZa6ZJBYD3RrKA5+Ra3mJcpoc7TcIboI9eMtq0A
	n890ehbTF/UT65IBH2ZEg37g8uNLjDtfj4eGj6m2LrfZv/1QEVemAMEZIaKwBwIUd/xIPaKfCl4
	vIjPc1hPA0h198ZBjCUxJpX6hgfKOizN//Sxr/wilDra3aX1s90WfwG5NlDbL+86uVw==
X-Received: by 2002:a65:5b4b:: with SMTP id y11mr18131595pgr.244.1561491479658;
        Tue, 25 Jun 2019 12:37:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLPNvR55PUv3mqClFRCMXaXtdrYOEABxYCH3WbmvP+KXa4BKmLf+NIWt64LQVLUw6wVENQ
X-Received: by 2002:a65:5b4b:: with SMTP id y11mr18131542pgr.244.1561491478851;
        Tue, 25 Jun 2019 12:37:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561491478; cv=none;
        d=google.com; s=arc-20160816;
        b=tmNDU/DqUridLSV4ZVG3o0hRrc5cE4CRAK7+Yj5Ku/PaCpr1nqdZr5+wK8mu7G1NyZ
         ZdBc+WX5kfz59zlfKSmK7IKGKmsxuw9H0/R/eBTeowRZ23TtAFxaMDHpzZs22gNlElEP
         qdyKfEMPq52um1+ah0Xg1fVY0bHvgt3usf25cDwN0CJwQVxGLV1/rVL6OhVArBqxdjPk
         mpr+C6ZdX3cls1z6lg5EtnqnK9SC/CWeCgLlPrYPOBYDO7YLwZkPdIZSLInuhTARwnFt
         Z9xZIYx6Y890pP73Pk4hR4qjNttrX/nj32oY7NgJvbvR7rD+ejJMOkShZWtraKKV6f45
         oIjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Zm+xExJBLveAa0DN5YO863/tHrrTEPNBV4jQ46p4ifc=;
        b=MVu0xlOTGsDDF2s6IJ+JNleJnc9mbk2fu0uSVpZuuTxbKyUgBTuFlZOpUvaQ+vn2Pp
         45WrLaPmsgz7YtKfggsVCGYLOFP8PC/MUDS9bsG2WYR6AMVucDxNFouMbdRU4KJ0kOo4
         YxOKKCtaM1YQB/2/eru67mCCcKGDc9SrOyv12sq+LmGIVTu51R0tFsKAp0SbQyM4gjr7
         NgCB9V0r9lRK2iaNJZnxTL1gwoBPcm/I65hn0du4rz2OhQ+MrGfm2W2N7ufJMEnJYZl7
         te907pb8HDiUxCqY/hvR2aDvHhz1cQuqIpNsSi7eDSfc9S8w1X7AQ5mzMOa6neSCiO1V
         6LRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ShVOA7PY;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y66si14951588pfy.197.2019.06.25.12.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 12:37:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ShVOA7PY;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C012D2085A;
	Tue, 25 Jun 2019 19:37:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561491478;
	bh=tJdGNjp4NLA7f2CJGKITTf6uA4kMX96bLEi69D1RpFc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=ShVOA7PYXmmz24tjLGDu1PYm64KCDa4yjeLXa3l6FjdwwPWxrgsVBDxgsovdp7feN
	 blu+puyvqldhGC0Wxv3kVwuVBCy18spQuzJMsEad+C5F0wrxmqqgxgvTR3f1e5CyBT
	 eX6OYwNFOGaN5Cpc8zEu5AANzUORLi6PZJBbAynU=
Date: Tue, 25 Jun 2019 12:37:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Paul Burton
 <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S. Miller" <davem@davemloft.net>, Nicholas Piggin
 <npiggin@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrey Konovalov
 <andreyknvl@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 linux-mips@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 14/16] mm: move the powerpc hugepd code to mm/gup.c
Message-Id: <20190625123757.ec7e886747bb5a9bc364107d@linux-foundation.org>
In-Reply-To: <20190625143715.1689-15-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
	<20190625143715.1689-15-hch@lst.de>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Jun 2019 16:37:13 +0200 Christoph Hellwig <hch@lst.de> wrote:

> +static int gup_huge_pd(hugepd_t hugepd

Naming nitlet: we have hugepd and we also have huge_pd.  We have
hugepte and we also have huge_pte.  It make things a bit hard to
remember and it would be nice to make it all consistent sometime.

We're consistent with huge_pud and almost consistent with huge_pmd.

To be fully consistent I guess we should make all of them have the
underscore.  Or not have it.  

