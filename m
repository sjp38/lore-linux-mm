Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78FFFC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:36:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38B9C2077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 12:36:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="op8cY6PD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38B9C2077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2A306B0007; Fri, 26 Apr 2019 08:36:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD93C6B0008; Fri, 26 Apr 2019 08:36:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8346B000A; Fri, 26 Apr 2019 08:36:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5546B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:36:26 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w9so2497741ior.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 05:36:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oL8TTwWf1lScK+P2aI8yHUzecgCr0tD4qW+nChTl00s=;
        b=juAkcPyNQ2ZAPefn1/gZexQFybOK9a/HAFBeShaCMkowlUyA5GQuYJQPzphSpDcPfz
         5rGcHO1lEp8kHCDUNFCmVMGKR3JgBN8wPQr7+4NFfVAA2iRXtrAtUoQ2GlZKnMXyIbxm
         GXCd+3TfiMW58yLYGlLyAA2o/WjjX2uB2eVdDoAUFmFxt74LGANf5sfU+sKRRAIrnpNX
         BZqItcI80DB4M8QBGwX5cQY6RuILsBYEdiTJA5HpoZovsSaW36G+4LefxDUtGqGlO06y
         LggGmUUqRrn5I15yrrY9tZtZdcVEXW56SuBh2+84zLrulPB7GoyQtloasK0z4U+wR5PK
         J6BQ==
X-Gm-Message-State: APjAAAWJw1fRnNhDPC9fhErt25b+tE8YvwcMbENGHdi3J5ZFpuSSBwE9
	dYgvXz4Mijr1hZNBFY7DphL1cs1BitFGC0i2qBeHUPoiBKXR6+5ae99f+6LCnJjCn3dJ/zuHSHJ
	HqcyfRnSkrJvQWs1JRLFuFp2QzMRkKRRTZ546YbGp7x/IVvGV/pIO3Xxvib7zArbQDg==
X-Received: by 2002:a5d:8717:: with SMTP id u23mr30534727iom.93.1556282186337;
        Fri, 26 Apr 2019 05:36:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpYFLQPavykZVdK3ro2UDTnCZtjkhee5fGjThxiKJkLR2WtzqfI7rmrJCYT+H4ndHGgCUd
X-Received: by 2002:a5d:8717:: with SMTP id u23mr30534670iom.93.1556282185443;
        Fri, 26 Apr 2019 05:36:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556282185; cv=none;
        d=google.com; s=arc-20160816;
        b=JC15PtDfDfw5XiWRnKssYDcljKvytoN3hz37pXAi/kjtLuxTJqBQ/o8q+OxNWOQHLp
         jMVgi5CX+roNCH6+feqUIx2TQBvAsu25GgYH1ziHOr4IWtXmLJlRFOr8yUoHmbYoN2q5
         ZwzutJoyHgLnwvdoukUqeBUyrQVowpoFwBtiNMfVx+ghHS01krVoFgLvj/lN1eLbO2rZ
         tG6zTRHyltK583k1NqPrBdLw9K4/C819Xldl2daapqKRbzl/0NMB7usCZ7mHSaBHBcAM
         YSqMA186O1Ben/Zw5OJZyvVnROYjt1GdIjv+LRcDAk9/gp/emARf0LEgIYKAfP+m4S78
         +5vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oL8TTwWf1lScK+P2aI8yHUzecgCr0tD4qW+nChTl00s=;
        b=j63RYQRuTL4Tf6CA55RcchP5Ux7glRyEJxJ88eFIxzjW7YyIuWwD3fht4jlD2ghe3z
         Lld28X9DXCOVkEdDRmGWqTYLEwhw4O+SI4VW2OO1vgZMu4EC2m0+T0h4n1tqprZwsUZE
         nGg8A0nu7n10oo78bnYMg5KcVJGGlgiPoun5iQOH/TSb2FCBYqRjpfT47cP9aubunV4O
         RqjQjkDtObP6R3xNa6ASWo7YOrOHoxQLJXGtfCP2whPCc9on64LS+oEddGtCIt5/kPu5
         w5cZw56i1eTBtnBSYIfKUSYkqAmLOIufGNO1/UT8LIkSRtMQ7k1ayUXJ+r4H+odrvWrx
         b+7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=op8cY6PD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id r10si15225885ioh.31.2019.04.26.05.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 05:36:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=op8cY6PD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oL8TTwWf1lScK+P2aI8yHUzecgCr0tD4qW+nChTl00s=; b=op8cY6PDBfokaJTi0IoRoXdKK
	wAZ+Ad6aX6IxVamFRPcS1dcY7bMX4xn6KYbwmRYjeSZx1kzjsbYVtjeEKMn5g+I9jRqpc7NsKcl6d
	ipfvVSItPtEe0044dQwTYDEc6vLU7ATUKEjAawkv8oXsUc4nkHkux0vwu44fc0rbg6exJwzeMUIuI
	+T60zYaYG8yV90PEW69dsOOyNJTIGvdf1/HpT1FSTkOa89UzHU5BYAtjh3K0ciOahUKydkJ6uNSmR
	FqBuByl34lt3kovjo4NkyejsIlQJVyp0YBHCDnRz5chrwTtPogDXKqFUmgN1aa99n2k9uVbrXQfF5
	p6HK9g99Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hK05F-0000L5-Q4; Fri, 26 Apr 2019 12:36:05 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 060DA29D23253; Fri, 26 Apr 2019 14:36:04 +0200 (CEST)
Date: Fri, 26 Apr 2019 14:36:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH v5 00/23] x86: text_poke() fixes and executable lockdowns
Message-ID: <20190426123603.GD12232@hirez.programming.kicks-ass.net>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 05:11:20PM -0700, Nadav Amit wrote:
> Yet another version, per PeterZ request, addressing the latest feedback.
> 

Well, I would've been OK with just an updated to the one patch, but
thanks. Let me see if I can get all that to apply :-)

