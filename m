Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC021C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:29:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA5A24214
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:29:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA5A24214
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BDEA6B0272; Wed, 29 May 2019 17:29:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 470576B0273; Wed, 29 May 2019 17:29:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35EBF6B0274; Wed, 29 May 2019 17:29:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBDD86B0272
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:29:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k18so1523491wrl.4
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:29:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=jNPbjJ6jMTvsYkx9D+ynmU31Y+16DXpinyMLmftmKoY=;
        b=gjnKez3jqLnHIwTID7s0jNekQGJdCiYoYlLAeq79WCGsA/yNMEWYmFCxnctszuJeTt
         m1Y5982YSVzl4gB3jAo1gIhfhW50zo4rgwHmYJXoJAr8UEJZc0/eaztf3PN+ptfuXO62
         oCxps+Ie1ziLD2wtic9GGIYlEh0D07PwKIYDwXxZIuh64SmhSG0y6iX0SC3p79/oQWCt
         c+nTSFxgv9B53d5dF9o8wgEB2nniY2b+RBqt3Jj88Fn1cBQvoVdb8CJx08+AFGI2iMIp
         nz14pOrO0AqPZTMeWAGtWD9P0uLszAWhQXfyTfHQoQUxqfMj26V/f3IBK13yhnjiw0I6
         lBBQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAVqeQOQebmjRuaGc+xsdgNkyZq0WoEIxzy11Z0CkhzJHp+/mn0V
	v6ce2yi4KbrsmqplpTh/zfgmsGDf+lfNtGiCY7xidxQVw/PyUn28xiGT1jVHGC5j6e3Hw15Lyn0
	QAxRwyO/EbisYG0KigWvkylAypXeW8MdhAf0VXuDZNR9PGR2KXyS5Qc40EJ6sE6A=
X-Received: by 2002:a1c:7303:: with SMTP id d3mr80753wmb.119.1559165365416;
        Wed, 29 May 2019 14:29:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwggrYnfYEyVkcfjXtVymrsnSnG/Qd4L9b4aXditnWshI5o1DAOJN7r5o1/fr6RDDuKiBV4
X-Received: by 2002:a1c:7303:: with SMTP id d3mr80730wmb.119.1559165364332;
        Wed, 29 May 2019 14:29:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559165364; cv=none;
        d=google.com; s=arc-20160816;
        b=rXu1o9m2tGkS/tn4gGDngQ32TZdZk+qVvZLbikCuNDamzconHdcl2Rl/iaJijK9Uem
         rvvD9vlwkRQtKTcnVa5Iudzc7ac2FPOTJVCDQMmwXJhRcVWV2CSiximAL8CJYzWErYeo
         RxSxAWAvJOdcyqD1axoAQGyNf4tHV2SNMbEHFFhiyMEukuZj2nVcL7SkFjrM7wPg4A33
         nebBaOlBWwcUEn6f19zlciBSg1OM+JyYEIvIjsTTErrGITYOxdTKrejGYHivCabV2EnX
         hx+9Z7YDAd03VC45rtf9jBrr20zvYjZabqkRukJmTViqudctHFM+RjLBOIHXtmSuxMnS
         DL5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=jNPbjJ6jMTvsYkx9D+ynmU31Y+16DXpinyMLmftmKoY=;
        b=UlqRsZNctz9rHsCkWPmB1t7hqveY4KrwPduNbXY7vNcDw8gpUqBmBCgxObknpdHM2G
         0FYUJMPXgN1ZKkaMBI96moIVm+tN9Ck2glD01OcPn7n6HxRFbMBCvPdByBf5yps1z28f
         pIXj5c76XBl0Lya3iKXXFzb4TBdzSVwQYvIrp9rDrJljJla4YQCMEexsVCcbTXvsH7SS
         hnDjJNUnaaTBniqJ7h8lUiOsSW1xrEWTsVEOLEL5Cj/3l2DlI5aAdzp1Gt4Y4EERak1+
         tHV5c5vfw0HKj8e4lQYUiO+luCuUPNEjixgL2Or5S2xPq5OYOIz652IVKblyYcBnvA34
         RFxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id t9si543565wmg.34.2019.05.29.14.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:29:24 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16725551-1500050 
	for multiple; Wed, 29 May 2019 22:29:06 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@linux-foundation.org>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190529072540.g46j4kfeae37a3iu@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>, x86@kernel.org,
 Mike Rapoport <rppt@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Borislav Petkov <bp@suse.de>, Pavel Machek <pavel@ucw.cz>,
 Dave Hansen <dave.hansen@linux.intel.com>
References: <20190526173325.lpt5qtg7c6rnbql5@linutronix.de>
 <20190528211826.0fa593de5f2c7480357d3ca5@linux-foundation.org>
 <20190529072540.g46j4kfeae37a3iu@linutronix.de>
Message-ID: <155916534299.2252.10999808950517357760@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v2] x86/fpu: Use fault_in_pages_writeable() for pre-faulting
Date: Wed, 29 May 2019 22:29:03 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Sebastian Andrzej Siewior (2019-05-29 08:25:40)
> From: Hugh Dickins <hughd@google.com>
> =

> Since commit
> =

>    d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigfra=
me() fails")
> =

> we use get_user_pages_unlocked() to pre-faulting user's memory if a
> write generates a pagefault while the handler is disabled.
> This works in general and uncovered a bug as reported by Mike Rapoport.
> It has been pointed out that this function may be fragile and a
> simple pre-fault as in fault_in_pages_writeable() would be a better
> solution. Better as in taste and simplicity: That write (as performed by
> the alternative function) performs exactly the same faulting of memory
> that we had before. This was suggested by Hugh Dickins and Andrew
> Morton.
> =

> Use fault_in_pages_writeable() for pre-faulting of user's stack.
> =

> Fixes: d9c9ce34ed5c8 ("x86/fpu: Fault-in user stack if copy_fpstate_to_si=
gframe() fails")
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> [bigeasy: patch description]
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

I am able to reliably hit the bug here by putting the system under
mempressure, and afterwards processes would die as the exit. This patch
also greatly reduces cycletest latencies while under that mempressure,
~320ms -> ~16ms (on a bxt while also spinning on i915.ko).

Tested-by: Chris Wilson <chris@chris-wilson.co.uk>
-Chris

