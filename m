Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C745C07542
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 15:33:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03352133D
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 15:33:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Aziml0Df"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03352133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1257F6B0003; Sat, 25 May 2019 11:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D67E6B0005; Sat, 25 May 2019 11:33:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F07B46B0007; Sat, 25 May 2019 11:33:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD8FA6B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 11:33:24 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id o128so11645565ita.0
        for <linux-mm@kvack.org>; Sat, 25 May 2019 08:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WbqNo38oKnDgLfSlhou/YoifuG7iR4GfTM4BUKO+d6k=;
        b=nBjI//EPUe+pfDpZsocPawcRNDo6QQ9pO/rRdU+T7483JNYj17wVE2CuybZOS0yo+I
         q24gRB2zt28D3ludP8dImcFqN57Z2yfr+HgLI8rFW7KglsudTNTz6yNNgwdTanJQq775
         vT7bkeqkTr0vfQTw4FYz/HIfJz9ITMwvkTAydmR2alAhMJp+riq+G2mbDXnZlOzKsYlG
         PYqYYj6BDLJzmh4aYnN+s+ERcWo74cguxrxyhjKPMaGYqta63cAtUIg6A/Yw0iM4GBUK
         CslMc0ykHxX7qaH+G+i2mBQT7BxyYsZhbB17kpFvPyS+YSq0OcquVkxpp19pWq5vPCmO
         fqRA==
X-Gm-Message-State: APjAAAULfWFfULleexGf4VjsFKECdDyYjU68k+25d40P+rhQp8wamkcl
	yTdTsBXAtmNRxhCrDbjKaL1hnYAVkbcMpSj65yhBERQQX7ORYuByAVbtkyVnw6LQjeUn2TreZfa
	t++SbMtugNYlkolnBnAsMDq30c5n/MucRnFsVU7QpRv55ph98oOqZjZA7AEPbXo8qyA==
X-Received: by 2002:a02:3f1f:: with SMTP id d31mr2470664jaa.132.1558798404601;
        Sat, 25 May 2019 08:33:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0vTZTJM1nR66FiGX6Oz/OKdrsrkIw1S/E3eiJK8O3L+21xt3y4uqZidSJXDmYqIz6Rk2S
X-Received: by 2002:a02:3f1f:: with SMTP id d31mr2470625jaa.132.1558798403948;
        Sat, 25 May 2019 08:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558798403; cv=none;
        d=google.com; s=arc-20160816;
        b=tG7lGk2rd1a+8BL+Z9b9oCEZ0N4nZcZsAkWC/xfUKTlqAkevHCkFdRsU0LpHYkSIQ0
         l011DLa5DHdB+0R85fIHIBOlOyJ+jkLhoESbSwqZCeJ/1eMJlIONccu9woXcHl1lQ+IL
         8VIvSCutYoN5cxOjcHcRNyF72cGnaxAMzGW/fW+LEiHihQ2IPXwMuqRfathMflI+oyEQ
         44rAaPgXzkQEKip/vxqrec0TbENgdrOo7x+8pFi6qzoGOjDJeqrO43PBXulDxSoCT0wY
         Yag6V11vKUk8ZPclzSB1faf2Fn0ojkp1LS9wVwMRyqIhUBrEYJpzO7pDmfjA6zFBAfUp
         4Q/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from
         :dkim-signature;
        bh=WbqNo38oKnDgLfSlhou/YoifuG7iR4GfTM4BUKO+d6k=;
        b=s2WQ7ji5pQwcs0aX+eG++Lv8IeJEkD2G3ArmlDgZtlsjCzKK0vTOF21srj9yEYSNNU
         RnBUIM4vI31OUZmnj7QT1NZeItdfqYPmxffeNFHgzNq9Cq1meMMQfDSKoxAcqtho4EOI
         Vx8+pvYAWMX7YhhJPAZaeFBd1syl90QO7+8Wofnm3KOPtGXP5zo3tct5hfN9vZ0cgp9A
         zGlj7spQGLl+F/IsAxlyqc/V9F69alrGPeewzPjRP6RfJGdMBdnDCLLHefNA+PUjOJk7
         VzuLWuFnNeb5T/EyknjZ56idRxpIyVlhSu9IidDJI9mRkS6Ddf0SIfD4jSeEDRj9JVAd
         oILg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Aziml0Df;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p130si3739027itb.54.2019.05.25.08.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 08:33:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Aziml0Df;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:References:Cc:To:Subject:From:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WbqNo38oKnDgLfSlhou/YoifuG7iR4GfTM4BUKO+d6k=; b=Aziml0Df0lZtGqU4JQOokX4zeR
	W84UhKbObsOL6zhpEJztqvHhfHJiX1SE+rFAwG8XC7jNWzineA9cArXQvuYmMQxcq7ea7sEOLYLg+
	KSsYL+jkmVP2/jNyJgXgQzKDsmQU8QfgZXIKHL/MCgA1QsJJ20n2GzGmaMgDUOLm9ScDjzmxIV2wA
	rU93BaaR3mFTlUXz7dE+b3GSQNWfQhXaY77rHjTD+NLb55urKX10c9bTW48hfHL24tspy6aiUb0MA
	6FzB6TlYhpvEny2/wQPl6yvV3Jz6l+rZo3XgmDdJkrhJRl7J6rp8Rp0zOMYzqKkkbTF061YaC+9Xo
	yw0rxJYg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUYfb-0005u5-Bb; Sat, 25 May 2019 15:33:15 +0000
From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: lib/test_overflow.c causes WARNING and tainted kernel
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Rasmus Villemoes <linux@rasmusvillemoes.dk>,
 Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <9fa84db9-084b-cf7f-6c13-06131efb0cfa@infradead.org>
 <CAGXu5j+yRt_yf2CwvaZDUiEUMwTRRiWab6aeStxqodx9i+BR4g@mail.gmail.com>
Message-ID: <e2646ac0-c194-4397-c021-a64fa2935388@infradead.org>
Date: Sat, 25 May 2019 08:33:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+yRt_yf2CwvaZDUiEUMwTRRiWab6aeStxqodx9i+BR4g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/13/19 7:53 PM, Kees Cook wrote:
> Hi!
> 
> On Wed, Mar 13, 2019 at 2:29 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> This is v5.0-11053-gebc551f2b8f9, MAR-12 around 4:00pm PT.
>>
>> In the first test_kmalloc() in test_overflow_allocation():
>>
>> [54375.073895] test_overflow: ok: (s64)(0 << 63) == 0
>> [54375.074228] WARNING: CPU: 2 PID: 5462 at ../mm/page_alloc.c:4584 __alloc_pages_nodemask+0x33f/0x540
>> [...]
>> [54375.079236] ---[ end trace 754acb68d8d1a1cb ]---
>> [54375.079313] test_overflow: kmalloc detected saturation
> 
> Yup! This is expected and operating as intended: it is exercising the
> allocator's detection of insane allocation sizes. :)
> 
> If we want to make it less noisy, perhaps we could add a global flag
> the allocators could check before doing their WARNs?
> 
> -Kees

I didn't like that global flag idea.  I also don't like the kernel becoming
tainted by this test.

Would it make sense to change the WARN_ON_ONCE() to a call to warn_alloc()
instead?  or use a plain raw printk_once()?

warn_alloc() does the _NOWARN check and does rate limiting.


--- lnx-51-rc2.orig/mm/page_alloc.c
+++ lnx-51-rc2/mm/page_alloc.c
@@ -4581,7 +4581,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
 	 * so bail out early if the request is out of bound.
 	 */
 	if (unlikely(order >= MAX_ORDER)) {
-		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
+		warn_alloc(gfp_mask, NULL,
+				"page allocation failure: order:%u", order);
 		return NULL;
 	}
 


-- 
~Randy

