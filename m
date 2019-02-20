Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4BDBC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86E52214AF
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:23:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86E52214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34C4C8E0046; Wed, 20 Feb 2019 18:23:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F9518E0002; Wed, 20 Feb 2019 18:23:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 210D98E0046; Wed, 20 Feb 2019 18:23:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3D038E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:23:54 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id d15so1510901ljg.3
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:23:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uU3BEdmydr64lmMI8/tlF/8v6NFBxn1pOvM8p5nmeCU=;
        b=T789hfGMauslQcRPGwjLMdAyY93bPIapV8E+w0vm0kuWzp1rhWKGVWjNz9Y2SWLXC5
         5ntPf01D0NzmaXb5BnKAFJh0Djx0t9QjG9LbcuGdIfKahCEM/kOFu81GGwSPfGel7YIV
         amsh/gpvsKxX2nrXzvCDHjA951ta3BZoZFy9FiqrRFJzvaDm431IZYGGOe0DIYD+Yv85
         NsYuM0tbXe58QpI1zo4SvS4gzSC507otBnb9R18uRGuUAWn5wzsCnf2NBL3R2+KT3VCZ
         M0RH/na0u00Zkj2GQwgEtu5KAlWgt1ZRQp7PL7ukmyD/cgf9pvawMABvCH7rnXm+CP2s
         8rtA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: AHQUAuaA3IqGwM82k5/F2+sF8kiuHkLjI8ansEnxUDnJWKmMCWBiCbAy
	m1CUix5rQxwUqPojs61+UsDlNrrEanLm8SOqm4ngZoxDrROR9pkEiITTx7a8apEQaTJlv70JypB
	WyN4TuG2QdOqSpSPKUmMr5pzuB38kc3VcgF43L5I9TPdIsVuSoMqOnvoL0GI77dA=
X-Received: by 2002:ac2:555d:: with SMTP id l29mr21384977lfk.38.1550705034178;
        Wed, 20 Feb 2019 15:23:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYIU/thP6KaOq+g4QGSi5J9eoEBRIcD8EgxlDfZrCKMVWo875ThuYVVwgebU2lLTEsn0rGF
X-Received: by 2002:ac2:555d:: with SMTP id l29mr21384949lfk.38.1550705033189;
        Wed, 20 Feb 2019 15:23:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550705033; cv=none;
        d=google.com; s=arc-20160816;
        b=0Kj9NBWKBapQ4N7pWibNWIawMaqWWyqrSydA+e3uPge8DK87swgRGRXpjtJkiDKcb8
         v5JFoBEKHdevFFoCaJxPpc79HBewskdmPZl0IcSnhlzQnNgOKobI75HflmVzzi3IYfqG
         SnJ54BqLDpsgEHGw2DAOclc7PAisHe4D5847MebviFqHT3yER5VKoUIgzYCWQMWnMNCS
         XC9gj2veQwn0xjLk5EGLse1+6oXH78bV0VI7HUWjbCLeDsDpplPBvbI2syit1x1m9hoS
         y1LJdfGI4yzrrvSzbml47P2xqED/G60bQl0C7jZslWpFBQH3I5o/OgaVly7GHjV4KCwf
         TPTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uU3BEdmydr64lmMI8/tlF/8v6NFBxn1pOvM8p5nmeCU=;
        b=WWszQ5vIn34TSBQ3V/AM/YP6yNJpN/O0t82RVQJofXkLEvZZFsJKjaTrUnH21sDpnb
         FH4b1t78JGgORmkydbE0ipvGO37KvP4j9TNhgiUhDmz4PfkLfcGVstG/Hsv9eUw6njVj
         vaUsbuTxd6wPK9JoFzR2VRPRyBnWwdwaBFN+UTLO2Ufu187Y2sGksGKup4RCswLflwa6
         niZphdeTKznKSsFakxI4I0DoASZNLWZSZEFiHFblZgnPBk72w1Og+d4Y8zockpsUQXG9
         Y+kH/dWZJRwEmXIwR4Yll/tE/Yvz4Hj/MAl1Il5N8zkmjRpnq6E8XuZVgK8eRBYRpXqH
         nSJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id e19-v6si15704161ljk.109.2019.02.20.15.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:23:53 -0800 (PST)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, "Theodore Y. Ts'o" <tytso@mit.edu>,
 linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 linux-block@vger.kernel.org, linux-mm@kvack.org
References: <fb63a4d0-d124-21c8-7395-90b34b57c85a@linux.ee>
 <1c26eab4-3277-9066-5dce-6734ca9abb96@linux.ee>
 <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
 <20190219132026.GA28293@quack2.suse.cz>
 <20190219144454.GB12668@bombadil.infradead.org>
 <d444f653-9b99-5e9b-3b47-97f824c29b0e@linux.ee>
 <20190220094813.GA27474@quack2.suse.cz>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <2381c264-92f5-db43-b6a5-8e00bd881fef@linux.ee>
Date: Thu, 21 Feb 2019 01:23:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190220094813.GA27474@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>> First, I found out that both the problematic alphas had memory compaction and
>> page migration and bounce buffers turned on, and working alphas had them off.
>>
>> Next, turing off these options makes the problematic alphas work.
> 
> OK, thanks for testing! Can you narrow down whether the problem is due to
> CONFIG_BOUNCE or CONFIG_MIGRATION + CONFIG_COMPACTION? These are two
> completely different things so knowing where to look will help. Thanks!

Tested both.

Just CONFIG_MIGRATION + CONFIG_COMPACTION breaks the alpha.
Just CONFIG_BOUNCE has no effect in 5 tries.

-- 
Meelis Roos

