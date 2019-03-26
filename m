Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D485CC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 11:44:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 912F920830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 11:44:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GOz8h2r7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 912F920830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30AD26B0007; Tue, 26 Mar 2019 07:44:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 293F16B0008; Tue, 26 Mar 2019 07:44:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15DCB6B000A; Tue, 26 Mar 2019 07:44:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3B926B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 07:44:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id p127so11630076pga.20
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:44:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aAAXvmmTpqe3PtKH32pMXKJgd7/JMwI32R5uwR173Us=;
        b=RPQENv52w3N1wZZrDyeu/rPS5g87PlPuvzXtjUPa5BishD6SZkDb1bYhb429PYxYGn
         HVJ30Y7AczN1eCcffttSngUrSaKygNiGpQ1Ud9ddwKsSRDBTQEBtSS8fM2MQxmu57sTd
         Y0m8cKH9xJ1m5CYBh5yPdl7VxUgWQNRAjuI0azUlnUMvHdP1n8kkjPru9E1iwcsVEHHn
         xeoGICDArlA+HfFahtJY0nWmXBMduhUL6Bho9a+/Yy+PBprKLsWdATWhD2EvaNfVSDRG
         XuvvYDCYb8BkfMBo76uOSbK/TSggfl3femyeRE1KYD6eQl7IlRZ75trS3XnwHfPOYLGz
         2ssQ==
X-Gm-Message-State: APjAAAUfctJPP3qkOZ57wfYN7y3R5JUm42O4BeJgNYy8vjiklpBmDEi0
	b/zfqPKtXS0cS62Ql+wVGVJ6oOjwZsAd+hqU8U7HH4JZqJ51JsieVoYyApnu62HpVpokXYBVzuv
	h777yh0t4Yp83cjDiw+KqOjp01e+kdIKUaHLyNvwTMWln3tvsRKhAw4MrD8C+R6lCjw==
X-Received: by 2002:aa7:8d49:: with SMTP id s9mr28272549pfe.248.1553600641486;
        Tue, 26 Mar 2019 04:44:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzywaS5B+gHPaFSvZ7EDjnpYx6XDtg4MwvuYSpvL9pPdHZxvv/3zEsC5sicBgDWiju2TFM
X-Received: by 2002:aa7:8d49:: with SMTP id s9mr28272513pfe.248.1553600640828;
        Tue, 26 Mar 2019 04:44:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553600640; cv=none;
        d=google.com; s=arc-20160816;
        b=kB35KXx8GIqBLb/I2uCMKXLIuPwIFxLo7+XwdOI98Gsdfcp5QSpNCEhbr49X3h+HVY
         3X1K+rT9HtPm2aF4FytbKZMEvWbLMHZYQ7flou0oQFkUsfXsssnh6tvtJ4eWZknF2ekG
         qLK+KWBYHz0XYDWjDYTL+SgziPtk+weEZIBu0QEbhWe/SiPucLwPvF6oiL+sBwDJkepO
         T8T273p0HuzxodML9qrZGHE2IImlot4aau6HqHVfjbd6KgvKiE/poRdB0vsJLfuLz7rd
         gH9vrQYrljY2u48K0c9bI/SEETyjxa8rHl2BdDbxC0Omoobqxf7PWxTvZxxXY5wbpGR9
         6q0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aAAXvmmTpqe3PtKH32pMXKJgd7/JMwI32R5uwR173Us=;
        b=zYGa+Y5yYIFORcOAFi7gVT7Jp5ytM6l4yyqw1Lp6ssKH6bf2fK/LRn6IDtpXQvP04f
         4SoECmwuPCXK0wcYT1/gRIoY8+99ssm6Rdx5nPYSG2MmkPhnVcdlQrtj1KdP5heSnA6N
         KGhEaljUWZY0avFKEUV9rn4EGuMoJ6uOlm8lH6S5QNXnnmsE/EjGDi1I6/T3G3Pi9V19
         zDuEW6Pljhye6xDUePkE8QIzaxJuMcjN509lXwhYdgSY5azYi6OBBGfFzCCA+6I2WzuU
         nKN0RD7EkurDrBH+YXr3TwRI9avFFWv2f3L6PUetVcssGKFretVfYXeYiqQgEHR/Rhjh
         spQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GOz8h2r7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a25si15263361pgw.62.2019.03.26.04.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 04:44:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GOz8h2r7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aAAXvmmTpqe3PtKH32pMXKJgd7/JMwI32R5uwR173Us=; b=GOz8h2r7e1vwNGCBOWxSWQbu4
	8fdYTyqMl51xZ3W8YhfGeKl/UVtqGgk2ASuGxrwHuwneOJA75P2lw+vim6JCPSc9U+jRFpDtD7Pdl
	s5ppQKd/lFiKG9sPY2/I+HHUHQ0Mh0LxI7V9wHj77oq1GZCdhMQJomdGKLRMF38SWwQgQc1jTyl0l
	5y3BAxKmxUuFy2XK9g74vhMi06RkmAV6iKBh/RnFi0pgZ6Tt43WVFcFMTO9qDvPD78H0KCHWPFTRh
	CAn994OiEly0QewZtj2KYnPynOlF3yKN277iTJT4zt9wSnBvVK1JnyvAowlYyc3cyFgXSuEYeShZv
	UwquBy94Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h8kUo-000758-VV; Tue, 26 Mar 2019 11:43:58 +0000
Date: Tue, 26 Mar 2019 04:43:58 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.ibm.com,
	osalvador@suse.de, william.kucharski@oracle.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH v2 4/4] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190326114358.GM10344@bombadil.infradead.org>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-5-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-5-bhe@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 05:02:27PM +0800, Baoquan He wrote:
> The input parameter 'phys_index' of memory_block_action() is actually
> the section number, but not the phys_index of memory_block. Fix it.

>  static int
> -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> +memory_block_action(unsigned long sec, unsigned long action, int online_type)

'sec' is a bad abbreviation for 'section'.  We don't use it anyhere else
in the vm.

Looking through include/, I see it used as an abbreviation for second,
security, ELF section, and section of a book.  Nowhere as a memory
block section.  Please use an extra four letters for this parameter.

