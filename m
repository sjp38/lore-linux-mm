Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C003C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E338F2086C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:49:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E338F2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93F818E0002; Wed, 13 Feb 2019 12:49:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89E628E0001; Wed, 13 Feb 2019 12:49:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 766068E0002; Wed, 13 Feb 2019 12:49:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3E48E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:49:23 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v26so1316417eds.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:49:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SdGW4x7LCmOzxgCfeT/AVSPoE3+8JDgh8AFCprcC0yU=;
        b=NHOGowH2gyvO+04bLz7LFESaFVoD6zzIFY1XmrjD+HVLXKf3jiFk+bdbqkRa37F31Q
         ZUjcA3+1i/9qABm+l2+KjCjQr0i7YaNHaqlInexLOgeHmC+qDcOqw4KHP9Yhku5ScPLc
         ZpBRfMK7S9QOvdTVwVv7tNOWs+7N7Zip5Bd3y1NXwzuBw4McJNfgY6AJuECQsErNAKf4
         X3lSzVREiHcplmT5Uv0jfAVhna4MtNQoHl5th+O4vFKYjgV5WdrVpBMdiFSmNXlPH3RU
         QFxmUfByyceHV7FpUZYGhyqYPZvD87Gixng4U8zNdxXSlsNiyNNMJjLutVLBx54iI8oZ
         I06Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYOZIbtJuZw7/KQmtqjS8WZNCrBWDXSNt9M5/ZMvjIN3UEtH1o0
	Yek/Q3ecRvz46S3gmziHwrgcGMD26H/L8Gu6dQw/ke9OduyK9RiEY8q3I987LGdMe3iBdpanzF0
	RBI1RqC/7HdgRTjZgrdTRaWAh02a9FD6lhuUM4aMddgFNIJYSaClqRa1jEhRWaaVtvg==
X-Received: by 2002:a50:e1c7:: with SMTP id m7mr1337473edl.166.1550080162758;
        Wed, 13 Feb 2019 09:49:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaMqhayC1kDljUQ5ZPGvTeJ4at1SDcwjc+aNCRq9Mv4tsJUZcNgqFcJJUJ6orkEVZh+D1ED
X-Received: by 2002:a50:e1c7:: with SMTP id m7mr1337431edl.166.1550080161963;
        Wed, 13 Feb 2019 09:49:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080161; cv=none;
        d=google.com; s=arc-20160816;
        b=z0IgQtypotwTregkMHUK6chV8+nJz5FT85Ezf8bWQ7fPgt8wbqjmFwLrEy1Jr2KLiP
         J1Zb5UMwnL9tvnzzIkAhgZDU/fsqxbD9thaTIXzgV8o+XFhP0JFGWCrteOJlmacf2//T
         6V86fvcrp8xgu3sE/ZlGc1R+WUZge21QaZQOCFZkcq8X+NNCdKTzd9/B4dl9mhljb89g
         DdoLuJZb2/6JOkiN4PuV3MYLzhjMym/lUdamDCm7kxf3j5YJPDLlrdITtb8zNsuYIy65
         vznRCQd+FI+dcY/PJ8dJvqWCQVhHTRLH/4abIq40UZgjFYeMikALJrbxfxEHHOfm32El
         HSeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SdGW4x7LCmOzxgCfeT/AVSPoE3+8JDgh8AFCprcC0yU=;
        b=iAmWGhuaok6hUgdg5D+m4rqhHeQACVfP9ZEoX8jAIduFUf6Zvbr6au/5MRYdQnGLqj
         Imxrr5Bw5piMqaCvzsXo5mPrf2gNGUW2MPbyNBwVFBqBOJY201Tw/gEAaRFlDRA8jVEC
         /Oqcb4yD42rllWSG05n4IyUqLsv3sZCsp4Y1qPFVTBo2aaMkt0Gg9QJaAy+JlHXKurEe
         1jkiqTb+2QnvPkGTEwNwxXW2bVc4yBcNmakCeYWExMIpNmd9ToDGiMkYGA/2+hq9jp8w
         zrq931bUj0rdQT32rJTB/T5dMaRF+1PV6iSB4pAdlwpUrS6rhKFPfIef01LPEYMmnBYK
         a9zw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c13si5280367edj.268.2019.02.13.09.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 09:49:21 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 28BB2AFE4;
	Wed, 13 Feb 2019 17:49:21 +0000 (UTC)
Subject: Re: [PATCH] mm/page_owner: move config option to mm/Kconfig.debug
To: Changbin Du <changbin.du@gmail.com>, akpm@linux-foundation.org
Cc: yamada.masahiro@socionext.com, mingo@kernel.org, arnd@arndb.de,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190120024254.6270-1-changbin.du@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b34e8745-daf5-64df-449c-4ddef8f0ed23@suse.cz>
Date: Wed, 13 Feb 2019 18:49:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190120024254.6270-1-changbin.du@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/20/19 3:42 AM, Changbin Du wrote:
> Move the PAGE_OWNER option from submenu "Compile-time checks and compiler
> options" to dedicated submenu "Memory Debugging".
> 
> Signed-off-by: Changbin Du <changbin.du@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

