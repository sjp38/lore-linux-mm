Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6B41C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:21:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66D65208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:21:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dMyL7yFy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66D65208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED1C86B0003; Tue, 14 May 2019 03:21:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5B3E6B0005; Tue, 14 May 2019 03:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD4136B0007; Tue, 14 May 2019 03:21:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F85C6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:21:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m12so8534677pls.10
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:21:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5gY/FrzuJKQ2FR01A0lkoDKVYEffpMYlDw1IyGNKjYo=;
        b=SE5DmCQ2DhfCf6DXLEutylTX89fIkpTn6ICG8EPSYRQo6SEfLhtEycyY/5vaJVXm94
         0Ed1bCw8BIclbgKUVMdzmnbIL3mB7Y8kwo2N7UahsvFLCguklStH/DiWbCkh4yPe0hL3
         Y7CkzxQXosGj77m1s7wKZgogSWd6NjVA2Ej6D0PoRsA0UbpxrjwoVC9G2Dwi1LugHLB3
         qUZZN0VcfAnNrcRrNIRy/o/m1YpecOqz1Ji5osu1pa6XQCRiFl01uJkzdr2V23yRgtCh
         2jsvjDtX7yCKCpJ741CI0unTPL1s8eRF37v5JX0MBwQ/YAPY0qryozqnzh0FNAQTO0WF
         5/yA==
X-Gm-Message-State: APjAAAXgYwwaAOviOssaSsYxrD69TjauOhaDvNC4BZTc6wadFNmQjvsQ
	l8MbNfu0CfLgRU0Ogl57SSKGEIyKKaQRQo1LKhHil1H9HJyI77PEb4/N1OeriF86lAkww/oQ5iB
	YDbUJAFDAS97+2/GhP0ujHc79HNDJWrOhCkhVimz6uKITkVs4RUAeFMQPqMQ/T94fJA==
X-Received: by 2002:a17:902:b602:: with SMTP id b2mr36375494pls.293.1557818476258;
        Tue, 14 May 2019 00:21:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2fHrd0LcY1EF2U0hv49KSqO9hxSWTgrcYJ6xB4/SVfpzUWA51yJKMu58OhhCW7zvf/Hx0
X-Received: by 2002:a17:902:b602:: with SMTP id b2mr36375455pls.293.1557818475500;
        Tue, 14 May 2019 00:21:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557818475; cv=none;
        d=google.com; s=arc-20160816;
        b=NUW0n0PsmKUa64b32tNg+nght7pQlDWtK4qmV1JcmLx6N1+PPJKnASnf+yLRGxPbsW
         FyjWpWxpBzXKVAixVYflNGl1QeC7bBy69OafD8UlkX1hRoUZ5/fH3VuLz6GVGTEB2feS
         25gMOhOuyjzKeacZTS3oouvv7QfJDG8wAjd0kuk2cZNYqWySpdWY4X+Wo6Zhy6WDGyWj
         O+wOCYctvM8bke38hZYp5Re556xutCfdmdL3Wd1tsCrfE6ioh+ZwFwovO1Vf5GNCq3yU
         fcBnBIIzaB1y9Gxdmtx191aGzikQRpX7ijp+znU5mx/7fvOqCGxXIx0KSUp1k24bGH9o
         W/ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5gY/FrzuJKQ2FR01A0lkoDKVYEffpMYlDw1IyGNKjYo=;
        b=mAhuPhT49lxfEAnzuDvBIM0JiKoczoah+Of1m37yoShKxY3iEkqt8CThzoy2VU08+t
         teE4EEIrkL5ZMen11VxHDl7DuOIc948IxLSZn8+Lf0cnqD72/0ta+Unin5nZQ/HoDaur
         kslqujLdHHdII+DqSbIdcRELm2t7rO7KR4vGapikBu7z0F0H0Ke2Wnj+zydvjrAswAnY
         cdqf1js8nsmoT5RpO1w+7MR3nb68kvc9JgmMwfJYsTGv85HLEii+8ylnK+KmKaSy5k2M
         6jVwvY0s8X8d0gqtkB1ODiyDIg9GT7kVC3fKTso2E9tJ2LHdZJiaD+Mksw94R+T0TvX+
         c90g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dMyL7yFy;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9si20584202plb.38.2019.05.14.00.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 00:21:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dMyL7yFy;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5gY/FrzuJKQ2FR01A0lkoDKVYEffpMYlDw1IyGNKjYo=; b=dMyL7yFyBotXpf1bhUBEB/ekM
	rQHrC1RIyHATgW4sGM/lBtPM6Q/ir3W3nlIwq6M3NSy+7bl37qJAqZoiNp/rifd429r2FJQdiOwxC
	km7Km+Q0BaJrO26RbBUBd+yQ860nWQWEkhMu90tG+wHL1keHeJAFl42CxKjSUH18D75mSs9yFSDNK
	h/lkar2wvBlMUAD/qOXOEaaWAV6UMzx8YxoCbXPWPN7gvV0T28tvGXgicl24PuM7qeSIjyavVCsGY
	48pfo7ItD50RW8r2+DtYofmZyPaZ+/cN5U455nWPteIReQsZ7sBrNHp8pVGyPNIbEB5a3E7YHC0pW
	Bkzm3CScQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQRkO-00038y-3x; Tue, 14 May 2019 07:21:12 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6F1B82029F87A; Tue, 14 May 2019 09:21:10 +0200 (CEST)
Date: Tue, 14 May 2019 09:21:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Liran Alon <liran.alon@oracle.com>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
Message-ID: <20190514072110.GF2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
 <20190513151500.GY2589@hirez.programming.kicks-ass.net>
 <13F2FA4F-116F-40C6-9472-A1DE689FE061@oracle.com>
 <CALCETrUcR=3nfOtFW2qt3zaa7CnNJWJLqRY8AS9FTJVHErjhfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUcR=3nfOtFW2qt3zaa7CnNJWJLqRY8AS9FTJVHErjhfg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 07:02:30PM -0700, Andy Lutomirski wrote:

> This sounds like a great use case for static_call().  PeterZ, do you
> suppose we could wire up static_call() with the module infrastructure
> to make it easy to do "static_call to such-and-such GPL module symbol
> if that symbol is in a loaded module, else nop"?

You're basically asking it to do dynamic linking. And I suppose that is
technically possible.

However, I'm really starting to think kvm (or at least these parts of it
that want to play these games) had better not be a module anymore.


