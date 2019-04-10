Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1485EC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:05:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF7A8218D2
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:05:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF7A8218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74B626B027D; Wed, 10 Apr 2019 07:05:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AE5D6B027E; Wed, 10 Apr 2019 07:05:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5790D6B027F; Wed, 10 Apr 2019 07:05:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE196B027D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:05:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id n6so1213588wrm.2
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:05:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:subject:references:mime-version;
        bh=LcmKUenQqDu1wL4NqSu9omBnmY3a5jcRvDfJiOhPcms=;
        b=lmNGTS6wTV+ZK/vugvqFrlQmNUSOwWqE5TZ/pSsV1H/cTFo1EeIsPdYVQvc4ciX64W
         XhFE5deNwEhXwYaiASa5wcY2ohSOyM7fPuvsP0qdYePkddF/R7XmJsIALLkg6Bv9ny+N
         uNlMyfP4vvUVZfPtvXffVZQcYyRrnoIop7H9nleJkB2MBK+e0fm1hlJDKRE8anUL+KtI
         o54uxTtgSCK8R2sF51EPY0MXVqhwAeRs/1AVoLnqhL8mkDt8tDToy36jfXWWrzrx4tou
         bx3P1lUWUTXOmSepc7Txugzaig6HCFU68jKHN7yBKwSXMa3p7x2nQwSvTW2qmhzt1+6d
         lrjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWsOcO0lHlIk+Q4h7Tta54K3kO8ZH7ewevpJ+Vb0jFo7afAzVhd
	CilM4w6d7r2dn8P3nXkR+LTWkE1ugq5uxSM26oQvq4QcCXzerQ3uvxLt0VErvMn3BfwI5QgTCdf
	KzUg4eSc3f1RuAeoBSCwZshlEE90IxKVHPBON78IQ2eaVXlg617KORUzj6JfDmMhHUg==
X-Received: by 2002:a1c:c504:: with SMTP id v4mr2487089wmf.45.1554894352669;
        Wed, 10 Apr 2019 04:05:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBVz4D/zQnRqhy7GHrcF6wvvDwXUwPlIGxRn8c6I3g3uRGh2jFgP2p/8a/t37IxvpH3kpe
X-Received: by 2002:a1c:c504:: with SMTP id v4mr2487025wmf.45.1554894351734;
        Wed, 10 Apr 2019 04:05:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894351; cv=none;
        d=google.com; s=arc-20160816;
        b=ib+DIBfcAllOT0fc7ab7ti5pr0fWx2DeMiZOtl1flJwKnswVG2AbdvYSUzNAZewykn
         IEDHFJ2BreG+tAkdPrGNJmUNaN5wnBW4nKWJkI473/fxZAY6iISVCWp8Dequ4YS6J2Hl
         tiZiXOr8c1PobHQYm9JYI51h9gzYN4Rjwqq+CkHGBbjx60VHzEV7Ksy3B+cuSx95qOmC
         bpe6DNVtoKp9q5jU6HcSjdbnfhBTmDd9gdWusbdFa7dwhFcEWdh4qubmZOYObkYOr4P5
         pudPbbDBvilKFuhBwxpI8ulimLYfjxYWuSBmYvb5gVhKc12we0k6kohUjKHCz19CH/Df
         HvVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id;
        bh=LcmKUenQqDu1wL4NqSu9omBnmY3a5jcRvDfJiOhPcms=;
        b=AKLNCXx+qV6HmUYLSjequ6lS+jc5QInx0VvOE61X/hIYQTf1IWOV2KZiih5CydfzfC
         5Aq/p+oJ2UnuDCM4m8r+0Krudf/bFU20dIsVr67/8JhlDXDBELEa9hrK7cQZWthfQTqn
         Av0yPctu8cSCrd+ClYXZ69PqeotbpBidhJd4WJDuf6Hp4k5HlKrnDgYav3UI6B89GsUk
         BbuP3ua1/mlG8SD75/aOJKFetBOOdTkST+kBOULIPRmXEkWlCAfD7bHpq6PSWHVQeNQa
         eVvAXuRNBaZnGZtRRUj7kv44MWv1ROPHAEpU+wusSQPIlDhpydLhF9IjcU8EECqPBXfd
         dEVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 67si1224663wma.59.2019.04.10.04.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 04:05:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from localhost ([127.0.0.1] helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hEB31-00054r-7s; Wed, 10 Apr 2019 13:05:43 +0200
Message-Id: <20190410103644.750219625@linutronix.de>
User-Agent: quilt/0.65
Date: Wed, 10 Apr 2019 12:28:07 +0200
From: Thomas Gleixner <tglx@linutronix.de>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com,
 Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org
Subject: [RFC patch 13/41] mm/kasan: Remove the ULONG_MAX stack trace hackery
References: <20190410102754.387743324@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No architecture terminates the stack trace with ULONG_MAX anymore. Remove
the cruft.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: kasan-dev@googlegroups.com
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
---
 mm/kasan/common.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -74,9 +74,6 @@ static inline depot_stack_handle_t save_
 
 	save_stack_trace(&trace);
 	filter_irq_stacks(&trace);
-	if (trace.nr_entries != 0 &&
-	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
-		trace.nr_entries--;
 
 	return depot_save_stack(&trace, flags);
 }


