Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7730FC10F04
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 03:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15E322192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 03:21:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="s7pu0GU3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15E322192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8397D8E0002; Thu, 14 Feb 2019 22:21:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8BD8E0001; Thu, 14 Feb 2019 22:21:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D7218E0002; Thu, 14 Feb 2019 22:21:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C57D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 22:21:04 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id w16so6492930pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 19:21:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AwjRuM4DjzJtODtzZyEza48FzxTdsBFsERrlwqwdPu0=;
        b=WvuEqmmUS99RnfuUNDgNgwQq9I6ByknLiKYsuQZF5HDQMLtmBeQPu5AcEfkt2wYOMt
         CV5Ezi3h03Mx+MmAI7HVKQwMLqZeS0g1K1Bzcr6EdmFLdHjlp71ScrldIwSaK1hVtOCB
         OrwvLYhZpTmSFa+XBVcT+t/tGVdX79LjMQ+E8wjlWdHjxbgJ0aBTaLv2b9y34OCZ7K24
         n1TFvULuQxq77/fEiWnBmOxzYb9i8XKF2P3tAI3mywUkMgceitdzDA2oZ2/482wjVbKe
         5x+j3cxXwdugAfAoDoVRGhrw5va/kDXFKovDegq+8vU41xwJ8N3TjjgxNDWmPHdy3kA/
         QTUQ==
X-Gm-Message-State: AHQUAublvBAVPTxjBRCP17vuP1YZJGq0Ix7LTy+oxMCQgee7Y1AsTLGi
	7hshBWCvaatjc33akoa5u8YNkDFydfSOvawxtXgrUBqFsTN7HwdGAR1mnZO6PVCNSPw8cUk5Hdw
	mJ28S0ZvQiWVBqxL8EVSS8OVLAotDzhG+5H3oQeXQ4H+yWqgVCbmK6Qfb4Toz1Qfv7Q==
X-Received: by 2002:a17:902:b114:: with SMTP id q20mr7862602plr.48.1550200863791;
        Thu, 14 Feb 2019 19:21:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbtuPhKg8djsj8KuXFFSGRIknZIHG8Xqk5lkk2gCuBycmrNPD7VQhzi5+/hrWm8FdHn2uIY
X-Received: by 2002:a17:902:b114:: with SMTP id q20mr7862565plr.48.1550200862988;
        Thu, 14 Feb 2019 19:21:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550200862; cv=none;
        d=google.com; s=arc-20160816;
        b=Gx0XC1FTZZuI+F1qripLLayk7xaI5znBeT1puQ57L96q4me651X6rX8qUuY9TTnzSy
         D9WJ5dRG5/A5xBr/uVjkyYbrVMB6Os+e7FHtLN4j8IvpADvdndOIySUCHkKQ7BpGxV+D
         5043U0l0aFHRKEC4rdnteVCqMK1jloHHFVu9d20nZAyPdqULKLlqOoi1JdvoCinKaY3e
         U70j4Ol4VPiPxCN8qSpB5nzyltN01ectYRiCzyiANtGerjncbw6jKEbIzX/jyQef5fHW
         vx2+3Cy7dDH3Or0Q8im9DxINmjlLe/NRem0N2wR3rvHNpLv0NoXWYcEPQJxbtRD+IzSR
         iTIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject
         :dkim-signature;
        bh=AwjRuM4DjzJtODtzZyEza48FzxTdsBFsERrlwqwdPu0=;
        b=wNldBat0Sbi101NfXOpNY0hzgJK7oAnEujjrBmHiCqsIGNuBaoeDXpPw02k1xNMgh8
         +prdqHTEapS+zZyEjqyn6yAo/enzZoywNgNQFhotHyFyxKbB9UKTYUrINprsqgoCKkiP
         yJW9Yu0IrAKGcqkQMXhl31WBTCakK3flqw6fSchrNoM1k/x86C0cZ2waWze86WNc0/bh
         eGTxHfzSq2IPbSuaJJVlaPXLyE9Ct3LMpLFDIp53+Vrlvq5O+N8L6f6xh2fjezpJD5jL
         ipuhgaVbjgtygoLUMN4MoaZX9y36Aa+TU1DYfKAiEpUz77CgB+2cEEGIuy85x8xw/a9k
         wX/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=s7pu0GU3;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a8si3816723pgt.326.2019.02.14.19.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 19:21:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=s7pu0GU3;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:Cc:References:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=AwjRuM4DjzJtODtzZyEza48FzxTdsBFsERrlwqwdPu0=; b=s7pu0GU3Gw5oDlkFcjXw0YxL2
	QL+VR19C2rXgiyR9bI9+ruPxvlr273Hj+FgUmE1EWkqn6GYK4J+Z9s/RFVEVo0Hy42ttiDsqSljlu
	fRSg3jscamcppMXnCfH3F6/vaDUOGO1e9Stp4enVSU2K1r5ZuNbws0MiPhSbaRp7gRLIO98LdO7RV
	dL+ybuGNp7TaRE3nfk1gXn8qNdZvjbrVJchizO/61bZVCAW7tD5TMH5LE4CT+KedxULQnURsv+dhB
	jSr8Bd50MAc59T8RllGf/I1nRcm0eDrHIeC7wdULVNZmLe1vCoT1vUtYnXIfdm6AHoPOK09alcNQP
	IKKHnh2nw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guU3f-0003sC-Bw; Fri, 15 Feb 2019 03:20:59 +0000
Subject: Re: mmotm 2019-02-14-15-22 uploaded (drivers/misc/fastrpc.c)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190214232307.rIB08%akpm@linux-foundation.org>
Cc: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, robh+dt@kernel.org,
 Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <44c1e917-bd56-cc51-8b65-0bcedfcd5f4a@infradead.org>
Date: Thu, 14 Feb 2019 19:20:55 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190214232307.rIB08%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 3:23 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-02-14-15-22 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (5.x
> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series

on x86_64:

when CONFIG_DMA_SHARED_BUFFER is not set:

ld: drivers/misc/fastrpc.o: in function `fastrpc_free_map':
fastrpc.c:(.text+0xbe): undefined reference to `dma_buf_unmap_attachment'
ld: fastrpc.c:(.text+0xcb): undefined reference to `dma_buf_detach'
ld: fastrpc.c:(.text+0xd4): undefined reference to `dma_buf_put'
ld: drivers/misc/fastrpc.o: in function `fastrpc_map_create':
fastrpc.c:(.text+0xb2b): undefined reference to `dma_buf_get'
ld: fastrpc.c:(.text+0xb47): undefined reference to `dma_buf_attach'
ld: fastrpc.c:(.text+0xb61): undefined reference to `dma_buf_map_attachment'
ld: fastrpc.c:(.text+0xc36): undefined reference to `dma_buf_put'
ld: fastrpc.c:(.text+0xc48): undefined reference to `dma_buf_detach'
ld: drivers/misc/fastrpc.o: in function `fastrpc_device_ioctl':
fastrpc.c:(.text+0x1756): undefined reference to `dma_buf_get'
ld: fastrpc.c:(.text+0x1776): undefined reference to `dma_buf_put'
ld: fastrpc.c:(.text+0x1780): undefined reference to `dma_buf_put'
ld: fastrpc.c:(.text+0x1abf): undefined reference to `dma_buf_export'
ld: fastrpc.c:(.text+0x1ae7): undefined reference to `dma_buf_fd'
ld: fastrpc.c:(.text+0x1cb5): undefined reference to `dma_buf_put'
ld: fastrpc.c:(.text+0x1cca): undefined reference to `dma_buf_put'



-- 
~Randy

