Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DD3DC28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 22:29:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 358B02628D
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 22:29:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KHCp4Wiw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 358B02628D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB6266B0281; Thu, 30 May 2019 18:28:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C66436B0282; Thu, 30 May 2019 18:28:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7D1E6B0283; Thu, 30 May 2019 18:28:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98D916B0281
	for <linux-mm@kvack.org>; Thu, 30 May 2019 18:28:58 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w3so6009507iot.5
        for <linux-mm@kvack.org>; Thu, 30 May 2019 15:28:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0VN5c421RywifIF8i/3tvMhN6mXfzQVaKnVDur62RGU=;
        b=qxCr3lOhMks41MdasKqsDHmsgwQXSjVoEJVK5QuJhGC54OTlqNN47CKLjykvDnFKX6
         OSfmtKTJN3GfiHQUHXpOKOr0TmEIN5SaRVKBclS6dLRVefyYkM02j9xp3EUHAq8YGlGm
         r/V+9Erltxe/N5c0aGMEvxN7SyM1lnjBbbMpgodujuiegKAVG4Oxu7wwT3YgL5uiqG7S
         S7hY14U8KkGv8rxUAgt1EBE4WfuUrw+rFcyoICELGkQT5/RKPIQCjYBLXLA+9lRH6lR4
         5xUjpEjX5Aec9fDgtcdyC26qIEnACszIqV6lNqpPrQlGW2FXymcCERgbQ7X6rsNNfDpM
         97yw==
X-Gm-Message-State: APjAAAVuol+lxwqCitsbFWJ+4F6YLf4fa6Tgj8ZuAJuMwSjGOSNQqx1A
	wely9rJUfuD4Rfku9SHJtEMLoS+5hkdBUe0EgfRfFuxQZ2A6y9d7A6z9ZtqlXCtrur6oe4NEWu+
	SU9OJc6AdSy5BcUv0xlI9FRxyeO+m9f2pb/VTwqHKHNeqHQk2ah+4ATf7I0mkjXlibg==
X-Received: by 2002:a5d:9647:: with SMTP id d7mr4475116ios.200.1559255338366;
        Thu, 30 May 2019 15:28:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKqZYso6aMvmpsa96vw6Mj7L0AQW89gzQ3VkzgEYWAMJDqg9JX20lThm2JJtp2XqyP528t
X-Received: by 2002:a5d:9647:: with SMTP id d7mr4475078ios.200.1559255337545;
        Thu, 30 May 2019 15:28:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559255337; cv=none;
        d=google.com; s=arc-20160816;
        b=Lnn8CdhkqrV7VsyvdhoA3YkSTlHsCDq4CLxWYOv/IignCBIKCUzesxuTy8LyZj3dY8
         YYPCC2vIHSNpAXgfLBzd/5Ni718nD600yiEFnn4BqDNfU4zzmLwSAqqBWOHvXGO3mSrL
         aN01hidRX1y4E2RxQbf8/PaZbqDXC2She7St9DHQJQ3/XSh31jrw+re360C9FLFmAj7B
         FclF6eyKjTn3qHi6MI1mzLEWUS66aQPdq2oVFrIi1xJf1+KP01zAvnSAm7vGbe+gIgNW
         zAjkj7BqrCVgM07rXP7Yqe/vn26E3Um95uCdJywY7cOvunRzKskRUT9bEZYxODVg98Qa
         TCTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=0VN5c421RywifIF8i/3tvMhN6mXfzQVaKnVDur62RGU=;
        b=Kyu6K/OIkgLLVdwm0sFlElSoy3/1TEoPpZwjA3hlnm8eHzet5dtYFCT0zpRe5aAguA
         puGtf2ArCa7aUlSsqiBIK7pSv7V8PdTL0tuTmtPGDqcVsd1KEVhPTw17CfsjwM3OUd/w
         mR/zTfvos10re+kbNyX6oRfD6xYiN855QJt9ttd+flwJ8xw94oWwKkhpfABClWTpu0Un
         fiGFeDj0dfKQl9aCtL28mfStB3DugnWkHHLiuPqiHRpd1atlaPLK4ibxf4pEG8XXRLIm
         PnqboLh+tKtTK0erosWS/kzgwtkiUmLv9jT8hsGt3Ec69BTDisa8x6v4pQ38jHSwf83m
         MR6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=KHCp4Wiw;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p5si2690731itp.140.2019.05.30.15.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 15:28:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=KHCp4Wiw;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:Subject:Sender:
	Reply-To:Cc:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0VN5c421RywifIF8i/3tvMhN6mXfzQVaKnVDur62RGU=; b=KHCp4Wiwwi+f9S4LXp2IJWa5zG
	SxnfG52Z9HxmHDW4gg74ulMSbpX0CDQGMZwMd+W5Zj+3lr0uW1f1hHekCH/7sjHKruEstLuNKJWji
	olk3QfhPAS/s/B3FHzbOEj2ynup7ZWk48Me/GhtfyzAVBus//uBGdH+fLD4xK6DtTkJ6b3VRkyThS
	4SKYhXskAK0TnZVr53SjW5ArJZZiNr6g6vNNrZqkCWt9zCwUk47K4GQVfBrUgqtecIi/gLuFzxFOt
	gnPfHcQ5hIyijGQfOj0LZgCOctO4GZSAJb0BvI+seY1CoYVj/KtS7DdWCZlqkY2ELPdulpDWaLiFR
	yLh9IG1Q==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWTXV-0003kU-A0; Thu, 30 May 2019 22:28:49 +0000
Subject: Re: mmotm 2019-05-29-20-52 uploaded (mpls)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <5a9fc4e5-eb29-99a9-dff6-2d4fdd5eb748@infradead.org>
Date: Thu, 30 May 2019 15:28:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/29/19 8:53 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-05-29-20-52 has been uploaded to
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
> 
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> followed by the base kernel version against which this patch series is to
> be applied.
> 

on i386 or x86_64:

when CONFIG_PROC_SYSCTL is not set/enabled:

ld: net/mpls/af_mpls.o: in function `mpls_platform_labels':
af_mpls.c:(.text+0x162a): undefined reference to `sysctl_vals'
ld: net/mpls/af_mpls.o:(.rodata+0x830): undefined reference to `sysctl_vals'
ld: net/mpls/af_mpls.o:(.rodata+0x838): undefined reference to `sysctl_vals'
ld: net/mpls/af_mpls.o:(.rodata+0x870): undefined reference to `sysctl_vals'



-- 
~Randy

