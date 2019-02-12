Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCE84C282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88F3E20836
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:40:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dLZ3YKCT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88F3E20836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 213D48E012D; Mon, 11 Feb 2019 21:40:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C44E8E0115; Mon, 11 Feb 2019 21:40:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B5478E012D; Mon, 11 Feb 2019 21:40:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C05BB8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:40:02 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o62so910489pga.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:40:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=A4uV7OxwwlFjvs3auauasxWHYI8sc0UwMreHo8r1FQ8=;
        b=I7q5PuDcCy8Z4NqSUG5UxfxTw4Yl2WdP3kSad6MQaK7edN/GPYSRcGbjDgQk0xtyXY
         jUN71KN/IYrk3mu5iXqldnksEcRH1Aq1KZK/lGZ9gyoHZrhF9bL89JmTSh7f/l+TbI5g
         REsw21OOc8SE4azsPRVPdJCSJ+Oids6QVcoUShPy/E05+wkIkd7rpuIsusxnIui/K7R8
         lvo+YECXLzqSPbJgQEwh2CrEcjDKw559rHFueLIe8I4VSgXtQlJEvDacYkudj5a+hzcq
         TcDbQ8NKrJtSCnnEjsOXFPWxLAey+Qgt+BoKnDTS6KOL2mXlQASpUDla+wufgee41HlQ
         n64A==
X-Gm-Message-State: AHQUAubMGv9MEDzURxN4MB0VUN/VZfgf2nLDCw3F8pldbWJEPDZ9MPNU
	MltsY26RQV/H9wNaL7NemLKy7nsDRM3KPJSBI9CFzMNYtq4q9Y/c0bxbejlA0hN0oABslHVSFvN
	3rs9lLXXeOYL5TbGxSu4fr/HiWoQjDuRK5Mfsf4K7RMu9CItL84NCFppWJXeqsymMNg==
X-Received: by 2002:a62:b15:: with SMTP id t21mr1662339pfi.136.1549939202373;
        Mon, 11 Feb 2019 18:40:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib64zj+t9WwA7Z2H3JkCUP7CuvMf0mizx4s8KpsHHmCKZTjy1Ri6kCAjY5/xm+LNigPV/HI
X-Received: by 2002:a62:b15:: with SMTP id t21mr1662291pfi.136.1549939201681;
        Mon, 11 Feb 2019 18:40:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549939201; cv=none;
        d=google.com; s=arc-20160816;
        b=jCB01LshbBNB7wAIoTe6UIK4yT1YuNhtrcJkwlF4psD4+RWnyIKIXCK5pEb3RZ5ONK
         HlzWJreGW+JceyTNxgX8PEimUE+bI+sUxNB8wLkfuN9AxFOSZ/eZF+yTA5z28HiJxO5a
         tcKEDMdwKnwtw29CYpSznYiyjdZ/KPiZvz/YL3y+yMTd12Q+7YgEtghJkPjkC5gN9jjt
         bALhl7af2vtl+m3Xls26/urx1CqCI6XTGv4MOIE46/RMcyHR+OC/zF7FYtcqEXoraWwS
         HUzL6BjXn1fyX971pZ2tVkKcB6FkEzKTW393skXynex3iLKfUkj9MysTZFsd4sxvPtzB
         nJ8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=A4uV7OxwwlFjvs3auauasxWHYI8sc0UwMreHo8r1FQ8=;
        b=vIvatS5JQOJ7001MUZNn7Gb2zAkj2pHSi6noHS01it8b1FfQIXRbN8fwaRdMP2/P+a
         xClSg2EJyPcZ/icGxOCdhJ8GJ/ClgFv7ROZ//Nwk3YUF1iO6TbG4C8zo9eFVLd+pwo27
         H7mjLVAYLagCfy8v7ZEfU5XyXHy0loDZ8dnYpFM0Eg7sR+E+Pz/th2pyalP8MaKc/0Rl
         /F6YDqH+jkgVKZJzTpc+0M4B8cYJEkoOPypTyP74qmc0K7m8YdVrqnmn5t+sFMySymGX
         dFWrEVgs1K5tdC6FHtN8MJKoPv1OBU1vH6lQmX7spFwrPAtGXx30w5zaE+CPqfPih2HF
         FrUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dLZ3YKCT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t16si11120251pgl.63.2019.02.11.18.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 18:40:01 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dLZ3YKCT;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=A4uV7OxwwlFjvs3auauasxWHYI8sc0UwMreHo8r1FQ8=; b=dLZ3YKCTVAmmJgA0OWYL3TZix
	OyJNL4vPuZLORMjtNHRZbhe5pf5Os3LJ9RGgyAsJ2EvcdT9wRO/a4KjxCqFsuHn+QtCep+ZYZ7QNZ
	MyjJaK/L778ktCQlYqY1wVphX6wGIxwxq+Tb7Pup8hIIFcokg5J3zdlRhNPEoRWK0YNlabtH2E+/I
	1jGsPYqSYmDhgWDsBtcJzkXNmFlrpTV48VRqy6HuWG8l8Vudy/CFPXfqcXAxK0wXDyhMB5Xx3N4LH
	Rw47FZ2vYK4g1S+opcWPmc90V0Gv8y1qfZtig1fjDJ7VwSXvzxOWczW7gRuwdDA2lKuiTvaXk4bGR
	oL34pWb+g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtNzE-0000DQ-KM; Tue, 12 Feb 2019 02:39:52 +0000
Date: Mon, 11 Feb 2019 18:39:52 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v4 01/12] __wr_after_init: Core and default arch
Message-ID: <20190212023952.GK12668@bombadil.infradead.org>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
 <9d03ef9d09446da2dd92c357aa39af6cd071d7c4.1549927666.git.igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9d03ef9d09446da2dd92c357aa39af6cd071d7c4.1549927666.git.igor.stoppa@huawei.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 01:27:38AM +0200, Igor Stoppa wrote:
> +#ifndef CONFIG_PRMEM
[...]
> +#else
> +
> +#include <linux/mm.h>

It's a mistake to do conditional includes like this.  That way you see
include loops with some configs and not others.  Our headers are already
so messy, better to just include mm.h unconditionally.

