Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6990C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:15:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A71C20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:15:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="s0SjHp+6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A71C20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22FF86B0007; Wed, 12 Jun 2019 10:15:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9186B000A; Wed, 12 Jun 2019 10:15:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 081E06B000D; Wed, 12 Jun 2019 10:15:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0B006B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:15:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so12073455pfb.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:15:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LeP6TwcOzXjrNratAgB9CTHzJxD6E/7uL3lYkwID07Q=;
        b=fSoFPQ2PsQK0auxMygMfRqUx8tOuiMVl+5/4tGV+OzIBxSv33BtPrSB2G5bT6+i7Yx
         Gp60Qe0gnhNg71SgKVA9nK/iNQQQkYbmi32YsLjcPPmSn1NvHh759ZAivzdPCy8C2Qox
         wRLeC1Aj73I8UBGMgVHIWgTaeQQ3GXAPxs0r61m/6UjTYME0afPSNYnxZKz/watb8Dyk
         6E9DWOkFrNStSrabqpgKzCc+/nOt5iIQtay5jirJPlrW4OaMXTqRshEHDAS/QpMM0ECL
         V265pSmKR6+N7x/JjcfgJLBwsJKT8LLmRXuoxK2bfVKqn23JHgc0x/g5vAJ5XdPCLyUL
         9Sew==
X-Gm-Message-State: APjAAAVji3duoWg6fL3A9Bx5sRP7Ve8+dAMeWEor7kE8WIQBISyAnR67
	N6d1Vfx4COjsPPaE3NyXaBYK1kcYIWeZeifE+3gBtNvQVc0kgyIxBeUMIUqZiLpnk8plvWyo87Z
	Wzin4Ww3XfCHw9fYVw07XUAJe//5iFoVHWIXI5He+fjFX6D97Xfp+nZeE1CNTJPMalA==
X-Received: by 2002:a63:ee12:: with SMTP id e18mr25974813pgi.412.1560348941129;
        Wed, 12 Jun 2019 07:15:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmhoXGJPEdrzxFP+wqTihSKJ6Conylx5jfShftEHjM1fgToDgxJDl9HxQafcmu+qJ14/iS
X-Received: by 2002:a63:ee12:: with SMTP id e18mr25974748pgi.412.1560348940116;
        Wed, 12 Jun 2019 07:15:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560348940; cv=none;
        d=google.com; s=arc-20160816;
        b=RTAqQPGaj3Wn6cae6qH0J5ufQtxyrZxbAg6DXOLKxB3EQlI9EQrdhC3J2DexF76Mss
         rTtFTt5BtghOtlFa4M5I8ImZtkTV8YfvN6BCv5UN4rlboCiz168FDRYwPWdvf1mme6hs
         gWt30NRFDvrFC6FE/HrY/bGwiBLyFLALkCBH1duHkVZtRUrDorVSrtNt04SdXbV2rlwP
         nUrUW2oePy31nUjWTgprojHJi8+cpCtrvZBXDv9fXTzFNlXTNh5SB8wHIFoVn0CWhAoj
         pfABkhBjc6Idu5omjXTc5BC3FnvDmvVyWhOyfQHg9+Gr6BW9mBdbtiCLH8PuRu3HKR4w
         C4wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=LeP6TwcOzXjrNratAgB9CTHzJxD6E/7uL3lYkwID07Q=;
        b=pYXPCeaC+ingb0VBASEFRGQmxPTNY5Uzen4S1ilezkrrkjIpRedrDbyCwEq9LDVUN5
         inHoJ4453Pttnkfi97fN371lzeq1kCnsx+hwy8Y1TSaWpv2yR2zwJJBvMAySLAL3sC+X
         VWqHphllMODHTv1UNN8/wCXl9DqIkuqH6r+lgHUxFwyAGchlrU2CLuq+YMbpwaA6gqaz
         2RDyHY9sgQDLv2RnyyUTPS1qAOAN939m2aSVSmXTY8yndqqAuNeMEiMMWYCD8dq5/7HQ
         4JYNlXEkaTAUHABWDruD8SKJtgEKrwpXgt7hoxQnOwlBTwyB+cvyRHjlQlSpOeMs5syH
         yqTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=s0SjHp+6;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x21si16287976pfa.48.2019.06.12.07.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 07:15:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=s0SjHp+6;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LeP6TwcOzXjrNratAgB9CTHzJxD6E/7uL3lYkwID07Q=; b=s0SjHp+66yKDoLfqPmmTR9A1x
	xcTi4R2hpEoWWXwekhD5QflpARm+Oj8OycE3A0RX9F5OXU4F+rUF2YQJr+wCY3xpXZUKIBQUn5Cc3
	5jQ/ySl8nFb1AaAQgSLxazJEoPy5Zyh6Yc4p84fmbTTcXaT9RtJcBFUw/F/OpU8oaN0dD/JqWgEmu
	SXjUyP2xKcRyyNx6Uw5TKxSO99+0TFJSHQVUb8Sucrtj5Jd/sjblXbbcUwekshFd4F4N0bq/klJMn
	czCGeNBi6g04ppweLr8qrgGe/gmzQWJ5uvUrbUK9Gdp7wDd+s35xv6RDK1BW2e9jbHipenRJNW7/P
	a5hzYJ3TA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hb42I-00012U-17; Wed, 12 Jun 2019 14:15:34 +0000
Subject: Re: mmotm 2019-06-11-16-59 uploaded (ocfs2)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
 ocfs2-devel@oss.oracle.com, Mark Fasheh <mark@fasheh.com>,
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>
References: <20190611235956.4FZF6%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <492b4bcc-4760-7cbb-7083-9f22e7ab4b82@infradead.org>
Date: Wed, 12 Jun 2019 07:15:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190611235956.4FZF6%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 4:59 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-06-11-16-59 has been uploaded to
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


on i386:

ld: fs/ocfs2/dlmglue.o: in function `ocfs2_dlm_seq_show':
dlmglue.c:(.text+0x46e4): undefined reference to `__udivdi3'


-- 
~Randy

