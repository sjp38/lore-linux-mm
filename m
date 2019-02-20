Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F6C6C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 06:31:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B718F2183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 06:31:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B718F2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 112B68E0003; Wed, 20 Feb 2019 01:31:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C17D8E0002; Wed, 20 Feb 2019 01:31:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF1A58E0003; Wed, 20 Feb 2019 01:31:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A09D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 01:31:10 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id d15so1105188ljg.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 22:31:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=K/TySU+LkRkWIo5VUpWQjPSBFptpU8+F/tkE0gcoYT0=;
        b=k7M4/CxRKqiCya5jt6uGIFB7hDlKxrDi0BKdKcln+i9/7FiZJM1pygZNmySu1aRqTN
         8+UGC1hz6/UFo9els+LQUhF1ruIvseJTeELhXlVU8d9L0SG+n0RJl5og6SQQD8WTtXAq
         Q8ykW/jb4LaBRUyPhjImv+Tag3mg707e6azKpOZBFUdPlX6/bcPI/3kWF2sTzap1GEsa
         RWAvuYlXLoZykr98y/usrQSbooWnoVi3hQjjJqQD7T61QD2kjCXV4kK9FYQZ2Wq5Yl3d
         XyLffq5pLj3Q+GbesWbOkLLSMFjwjcWtiPxtuKnl46wqQypuAUJF+5HYOpwfbSB/iTli
         fG3w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: AHQUAuamhYEgb5Ho46A9of2MAQ6+enCJw8zqf05Bc95UwJj0Vt8J5CC+
	fEGOBeVEEbS5zvA1QmJlu9tLAP/1BLxFuhx6FplgLmFp7+0ZnmDu+GI2YLJ5nyyOOh5nW9XgdTY
	Gu6Vew21EMhj4TP87F3KXMKwtvK7W0MJWm3G9kHmhvZRT9mT3MKPQTfjY8l6Dhf4=
X-Received: by 2002:a19:5205:: with SMTP id m5mr19324963lfb.61.1550644270010;
        Tue, 19 Feb 2019 22:31:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1Vbzg/R4jnzpapun0+sTEM5fi/+HVnkvgyai+BCeMMVrtIOrdB8H13Gx7I8IbtrQrqS+5
X-Received: by 2002:a19:5205:: with SMTP id m5mr19324910lfb.61.1550644268725;
        Tue, 19 Feb 2019 22:31:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550644268; cv=none;
        d=google.com; s=arc-20160816;
        b=lrUas54SoRbY6QpWnjWXEZdGADdwQl8b4YTVlpQbJka4do+ekOyQlAq6h0jiln7SrL
         Mrx7hpwmSUhqrwa0EAKGKUg9ZGXr1XtnEJ+MPpZO/8yARxALriUMFFBcVen9PygTG4UW
         Z7tiRSfsbkffTsvA6sUltC9oDurjWetdzwvhbO1GatG5FPEqZf41ORiVxzE01gtly34W
         Q8yqyDOVeJtRtxllQsVArSQIaIP7GMT4oYVKxtPS3JFbdrkJMJ7jkXP/cBiwSjkr/4yx
         oizW8uU8NVct+xItoXyfRBeEgqjfqtYqz6tNOYxPejpVyQW9WsutmyeA120RSDpbHB3C
         OX6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=K/TySU+LkRkWIo5VUpWQjPSBFptpU8+F/tkE0gcoYT0=;
        b=U7O+p4PZVYMGn2DZNE83JlGYmaOkk4++Qtl2gQ9W/PNjK/rtUSCAq/Hq515IstkwTP
         VmynLHDdcehBYdkJbu5/z67vobOb7CJ8NEgKfDS8ag0W+VexSU3Y+j6Pka67iRapVxbc
         OLt+ZqHLHpTcjTgT2yPDDTTtxpGQsWKVnDkQ5viUZFM6VdSZrtILcqJZSiCQv0qRiesR
         A3B2F0X3QNCIZd+hsYhUBgvijyaY4ZYnFzckPeGXYhwVQFY92ZSH1GYAxwK90AqSL2ck
         9IcbZEnxiy1aXJJIlGNCZJ+MG5arz0/AIUpRM7Ay51wFtSIjAU4lcQJAip9Mw8H1BhTS
         NQyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id w16si13316933lfl.41.2019.02.19.22.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 22:31:08 -0800 (PST)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
To: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, linux-alpha@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, linux-block@vger.kernel.org,
 linux-mm@kvack.org
References: <fb63a4d0-d124-21c8-7395-90b34b57c85a@linux.ee>
 <1c26eab4-3277-9066-5dce-6734ca9abb96@linux.ee>
 <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
 <20190219132026.GA28293@quack2.suse.cz>
 <20190219144454.GB12668@bombadil.infradead.org>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <d444f653-9b99-5e9b-3b47-97f824c29b0e@linux.ee>
Date: Wed, 20 Feb 2019 08:31:05 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190219144454.GB12668@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Could
> https://lore.kernel.org/linux-mm/20190219123212.29838-1-larper@axis.com/T/#u
> be relevant?

Tried it, still broken.

I wrote:

> But my kernel config had memory compaction (that turned on page migration) and
> bounce buffers. I do not remember why I found them necessary but I will try
> without them. 

First, I found out that both the problematic alphas had memory compaction and
page migration and bounce buffers turned on, and working alphas had them off.

Next, turing off these options makes the problematic alphas work.

-- 
Meelis Roos <mroos@linux.ee>

