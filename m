Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ACA1C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:10:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3EAA21B68
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:10:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Nu39IdlO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3EAA21B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BA008E0002; Tue, 12 Feb 2019 22:10:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 369978E0001; Tue, 12 Feb 2019 22:10:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C888E0002; Tue, 12 Feb 2019 22:10:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0C088E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 22:10:02 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h15so770205pfj.22
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:10:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=YTJqe0BFIXEHjERP1CPFfEIYWeKwxFAUWIz6qSWu6fc=;
        b=Ly1Z5JU0ubpiUOmvSB/1Za1Bq0cdmP/qK+lNemkNFFFlwUzRBuB+ow3fkdyy0zzSwf
         Uvcb4oYW+o7gsV9a5nxhoDSPYM5wQd/qaruPlig1RSQZfXDwrUuqHKkPGtHyaWkh5rPQ
         rFIOmchVYPo9M7ia9mzxIrL4zmNGR60T43S+3BeHd0rML4XWen2/9OVo485QczAg5WWi
         f6bIYXNU7t2JyDb3ymlWB99Rbzf6WsL7cvYaBFn3RSHMYF55MSGv/kOVOa6ZwxHBV7NC
         wAzudYmTlbOENTM4DUZbS4TQt+v0WtHE2WgpRZaAISkcf4hDxOvtQkIxDTs74a+Gj6OS
         z1tw==
X-Gm-Message-State: AHQUAuZtXBtehUcZKYrPXAevXIogizUzll0A9iO+KLkb4D6EDzhtqbn4
	zxRGK5lkMcY31PpDa2uzYyNfOonM4mIsF1WivcFyyhvTMn813kt3G7zXHqWDMjZ1ZKDMjNfsOEk
	M2wVEabq0PYKhycsvNbR52YQmFUoeROaTpVtS58N+OwWGEZy6dn17hSXRqIq6D6GOTQ==
X-Received: by 2002:a62:c21c:: with SMTP id l28mr7252979pfg.74.1550027402438;
        Tue, 12 Feb 2019 19:10:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYIKnLBWzUhkUrr11OqCcFujz6aUerXxC7tcgph8nYVaEntb6y5pE+sMo5Gowr3i+XZ3NUI
X-Received: by 2002:a62:c21c:: with SMTP id l28mr7252909pfg.74.1550027401515;
        Tue, 12 Feb 2019 19:10:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550027401; cv=none;
        d=google.com; s=arc-20160816;
        b=KdtXNSWsawiXRry8LJENlJua70MbJF7rryLX7MV0HFjJ2zrqF7JS/ck9Fxxc1npY37
         7uGnG+sNbD4jm0kQRoUWM/feQW01vesFnAJJEfF9FDwqFh7dPr7WgyDNtnyY5OfAiHNK
         5dTbDybUvV5KKzEMGnAyQyJWiVH1pKqicUd+a9wlU+PKTBihJLj6nnQYrMIoJ6jBbiHZ
         TwAz/Rm0XFgg7UIxE1S9ytbN6axmYyijfZ8n2M2nWoRbYXGY8xWXm/RB75DM6da82RS+
         NAKexbkoi3lIZiKtIzotOlSp2Xo4eYqPqBiJfbuG5a7mZhGFbs9tqfEgmvvSUZosVSuC
         9GYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=YTJqe0BFIXEHjERP1CPFfEIYWeKwxFAUWIz6qSWu6fc=;
        b=NITT4fVLy58Mx+pxCI1fXaG/OQJ6Hl34g3MPASLPEhyx77N3hl3AkH1eF5m5QiXclr
         J4RAF9fkDVIv2cakHuUS4gQ5r3rd9tvu5MBee7Pbz+2p/SL5t21K8N/uhcs8k5CB06mv
         RCpd7WV7dty4hIZpmg+9NDP5WEtxyE7bNdRqyhKzQESYuV7hJbp692rrMa7YdI56uVGm
         efFJxZLwjNbNwi0sVze8stkBK7Sz/LIBa0LIdwcfijy41wFqup94QMO1abkIibSIojyL
         /PgACRjKYI2pz49uyYwSLALk7gSUhIakSItgWkGfBtn+2RC9eAuVeZPdB403hVxLEkPZ
         N87w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Nu39IdlO;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g124si13362691pgc.568.2019.02.12.19.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 19:10:01 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Nu39IdlO;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YTJqe0BFIXEHjERP1CPFfEIYWeKwxFAUWIz6qSWu6fc=; b=Nu39IdlOGJtwfQhDDlccbR69K
	IFMK9UFQ1J35KW8AOHqmmvyKLDyJUVqalDHRkDy2jTmfa2aaEPYUWjXqxVFenBke6ZpwzmJQTaUTL
	djnHIXPZZVB96T6dGkXFSDcwe5rp4YuM0mt61Z9bdj9DaN+W/aEQWjROMTQOoynTPTBPlgD/EaNA9
	clXOFswoV29cQ1J6FskskMNsnXBcrSCeBI7q73AXs61RmMeqbHcHdhCVCi3kZbREowlXqETRz/upl
	xFjWw+1mSuKCqOL7ygu8XrTkj3+oVsYfT1fNT7teoyp2LJkgIaT03pPXDsNs3d7Yo3Ef1a2iya0BC
	9Y+pjlY7g==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtkvw-0005Vp-CN; Wed, 13 Feb 2019 03:10:00 +0000
Subject: Re: mmotm 2019-02-12-15-37 uploaded (net/ipv4/devinit.c)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
References: <20190212233743.mGzbg%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <011529bd-bae3-f815-0d7e-6da733c1cf55@infradead.org>
Date: Tue, 12 Feb 2019 19:09:59 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190212233743.mGzbg%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 3:37 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-02-12-15-37 has been uploaded to
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

on x86_64:

when CONFIG_SYSCTL is not enabled:

ld: net/ipv4/devinet.o: in function `devinet_init_net':
devinet.c:(.text+0x3ad): undefined reference to `sysctl_devconf_inherit_init_net'



-- 
~Randy

