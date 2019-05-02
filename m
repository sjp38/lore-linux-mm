Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 839A4C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:57:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 411AC20578
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:57:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="faB2OjTU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 411AC20578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA0736B0003; Thu,  2 May 2019 16:57:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B29CA6B0005; Thu,  2 May 2019 16:57:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A18C96B0007; Thu,  2 May 2019 16:57:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39CD56B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 16:57:13 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id l4so478105lfp.14
        for <linux-mm@kvack.org>; Thu, 02 May 2019 13:57:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=IM6gRPP9vGYAtrlAGvrZ2f9cRbqq+2XFYVZx5ounwgo=;
        b=FsZjtQBusClQy5hAhmYozuEFYpJ0UxElc0LGQXx4NGQSxcfdXLQhkC3Coh9h8h/o/O
         KOo/Cy1yZzueIhhB8r81XU3qX2HD0uZylw6nLFrGMsn7xeRMhuoS+4Wcj07jphCs33M7
         m0cSctlKYp6ApTl674zITNU6FXu2KiTHqDSC7wu6Ism2ONNpUHrYqdJDn3mj+PTr8DhA
         hIOamcS2f+LRXmxPPNnbaoRzf+4xUvgUr8pNDcXmbuNTtmLO4vRpO9lFrwe1w3sfC7BP
         anhifDztcP4D4qFK8bfAo0e46P6qEXr7yUYF6Nw2JBQ5UANF/YKovFDgxkcmRXroam82
         bp7A==
X-Gm-Message-State: APjAAAVFx5Ln4RznqdSzQYGUGSURSOPHGx7L5/WKQ54cwQhU6mtyWo14
	L28vXPJw1Cgrdj57ce1cQ6A8zZa8NCb29+Q7ICMmn4tuVzbciSUToCsNtt71HicSuM0CJhlaq2Y
	pSrpPTB40Q1hSPQSfI1OGgT15p6iKOX602hNL3H7WDqJ6htjUvglMFDIJRc5dIm83Sg==
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr2744654lja.49.1556830632399;
        Thu, 02 May 2019 13:57:12 -0700 (PDT)
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr2744619lja.49.1556830631442;
        Thu, 02 May 2019 13:57:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556830631; cv=none;
        d=google.com; s=arc-20160816;
        b=WVdZ87w0CmLq8XwVIDwePJ+HpkLE7wCgFp4KIafFzeejqDKQopFnwolDHZMEoBzbsZ
         V/zMhzNX1N7+JBppL6mAKsaFlbdz+iSs9CaJLTP4Oa7CQHojHoZkMDtbLZAWeP2K/OhS
         9k0BLKGYXi8LCJfiSHLLfMuqzopFTNDmrzoxKo+J/YMNty2Er/Api/m2jLNT4mwooLZU
         CamdEaMuqURogjf3P0GTe61MdbQYgAPvV68D09xa8kK2cpeNW6+xk/zOefZdtGc/PeN8
         JHXtDNF/DcT7AdJYLnoMNFn6jpeZcBsUJKV9D8Uba9jyztFcH8Pqdi5QP6HCCvRC7WG9
         L2QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=IM6gRPP9vGYAtrlAGvrZ2f9cRbqq+2XFYVZx5ounwgo=;
        b=OOMW6ZhBM222OEUkAwsjv/yTDWBeMT5EVGEHe1IAAHlQXK26asVuN6b5UE+csizIeN
         eGsuFWe4Cktqf0qIsgwzXC7fZ8CZL796ALX4C9FVeyXZmnUQo3yXxLriygZW93AaHxTE
         RHKF0msdB64lNGxS29KR/znGfcGffHy3nJxowP7nLrMZqiVmTf8fn7l9fxK6jRX7xmvI
         z/gFIFuoBcB2KCAqEAhh8NByyxm3XDBoP+MQNfJYNebgq2LckJcpwDqjRf0LZ6x2KaGb
         uzvRO7LLhcw4l71BxhUbP6qCdBkDmkjFFN6j5mO70IonAdnEbHlmCmg8+TzPQgX08Ibh
         TNPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=faB2OjTU;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6sor87454ljj.15.2019.05.02.13.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 13:57:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=faB2OjTU;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=IM6gRPP9vGYAtrlAGvrZ2f9cRbqq+2XFYVZx5ounwgo=;
        b=faB2OjTUqLUYYuLoMp7WpkRaNTZEgletqliLc0MZ4+/osrjMIZcLCcfxLJ8eZrgc+F
         pPhuKsTJfgrf8obzFfOQ9DBQswWwpy3rOilB/ZqgtZ6P7FAtpvwKlPGCcsEZiNfQYsGP
         sFT/rV14J7xZDOI0G93FUODYhEA2zSR6VoQx36G9kvuAdRt0XaRmiCNreHLM2HzGfI4T
         3e9FrHEO6d1DITNJXERhocTux647SkuM3zhlBM7n5lgxHkHVHWyrFTMyBy0e5dwPzHs4
         TLM3Hd9ZAhHg8Dpoasypghsr0LCvxn8F7uUpb05vRxf2ntvETOQUwmk7zJWZN6NrlsUv
         qr9A==
X-Google-Smtp-Source: APXvYqzpsjoV1s1hnIKwSS9e7RCryB3e50vVNZv0WlsQ5f+zrRhCvMjengCjsMlTvvMImTqrwmPAng==
X-Received: by 2002:a2e:81d0:: with SMTP id s16mr3098436ljg.145.1556830631022;
        Thu, 02 May 2019 13:57:11 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id z16sm40915lfi.9.2019.05.02.13.57.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 13:57:09 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 4AE3B4603CA; Thu,  2 May 2019 23:57:09 +0300 (MSK)
Date: Thu, 2 May 2019 23:57:09 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
	geert+renesas@glider.be, ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: Re: [PATCH v3 1/2] prctl_set_mm: Refactor checks from
 validate_prctl_map
Message-ID: <20190502205709.GD2488@uranus.lan>
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
 <20190502125203.24014-1-mkoutny@suse.com>
 <20190502125203.24014-2-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190502125203.24014-2-mkoutny@suse.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 02:52:02PM +0200, Michal Koutný wrote:
> Despite comment of validate_prctl_map claims there are no capability
> checks, it is not completely true since commit 4d28df6152aa ("prctl:
> Allow local CAP_SYS_ADMIN changing exe_file"). Extract the check out of
> the function and make the function perform purely arithmetic checks.
> 
> This patch should not change any behavior, it is mere refactoring for
> following patch.
> 
> v1, v2: ---
> v3: Remove unused mm variable from validate_prctl_map_addr
> 
> CC: Kirill Tkhai <ktkhai@virtuozzo.com>
> CC: Cyrill Gorcunov <gorcunov@gmail.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>

