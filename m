Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 883EFC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:39:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CF9920843
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CF9920843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C32E78E0003; Thu, 27 Jun 2019 05:39:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE4398E0002; Thu, 27 Jun 2019 05:39:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAADC8E0003; Thu, 27 Jun 2019 05:39:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5B08E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:39:09 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c4so1699268qkd.16
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:39:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=4b54uAuZ4BltrN1t2Af3HeuszVCm7fzlcea0qBuLP40=;
        b=AEMpcOdQ+MFAKT3rbKomxBCq2gC9bxnNZJzq2v+bP/pj4mtqdGzoAt/w0aD08kGSRn
         +m9O4xj81zTTTfz8/w0KS3AK7iJPnQ7hn8tDXhK/S68EZbQSZY9wF0Vr3axTocnJMy3M
         51gfZ8PgRb2YtsAXv+Gsswef28lAPeKhaBJUAa1cN2yNN56iZL4IjW7tweaGLsNCbm4g
         0prl+uVFfkyj2iOq3iqtyn/5k9OnwBnvSWZFg3fhYcsSGAL/9KbKHav3JR6W0U8WYf0n
         64TtD/y2DNoM97TJYfLOEO/Q8Y5A8zfPProVZDic7Djl4umsSOiUG2/MsDUNSrSF4vP7
         to9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXXb+rlBtSOli+9djwIAYE9MhxyjhM5MF2l+CJ/o5MR1QffQPBh
	TY6Ut+U2LysVdmIYiiQbG/5J89jPIvn+cjUQbkdD8VdHMxmFPQvOfRj/7DambWLBhoosv76eUQL
	4tcsmWiJIZZ9h25ON5X/6zod30bpGmUvq14BORU+QpuuYRm3s/PUw9wMUcIq8GydoXg==
X-Received: by 2002:ac8:2af8:: with SMTP id c53mr2208224qta.387.1561628349371;
        Thu, 27 Jun 2019 02:39:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWrKfP05HHRQnOiDnQjmfkOTBlg5fp0fwBtserQNycnUVgO+PnUwpqe8QfQGH3EGpBtBSX
X-Received: by 2002:ac8:2af8:: with SMTP id c53mr2208195qta.387.1561628348831;
        Thu, 27 Jun 2019 02:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628348; cv=none;
        d=google.com; s=arc-20160816;
        b=KCM3lFCgsurPM7FW7hsQzAGckrcmnN78A63QtHMIhL9+ce6L/yoxh9Fb3G31KKWYcu
         BGFRz4BFzejIgjq3tLjcj6uK+KKgw09YaKEftFLSHKWxIXUxkfg7T2NW3YNRCQOftYwB
         OHyBOalDKeZQsceJhRrvvYE5kpxQLjIXtepDD8fcXg/NeSLSMqLiFIWZEH1vLUMn4x+k
         Hm0/+Re/veEoCgyvTHUaZhuHEkja2Aab7wwSXkpTvwB3pWdaNwDVAYWIKzRdAxIeHfqy
         asQWR5pc8BUnZjXJ5bBnnUwZOtP3qOLtwDA+yVdJjYXa3m/2QWWM0xoQZMp/Nfrc5IN/
         pAeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=4b54uAuZ4BltrN1t2Af3HeuszVCm7fzlcea0qBuLP40=;
        b=iHluK2r2Ze28reOnHnylfUd0C9CLu0zijapcNwmqbjA7dKwZ9wgU+OuU4YICBf48/Q
         ug3XKYr8qzu53r3oPaqCyrktAbqKCr0JwRcB0gmERajn5ysvWn/GW5rKyY5TQ116J/cG
         SI45C8tXpv1OlVzWJ2bnUliFa66Q6DZv3Y62dEuk6l1F2FLTfZwoNzT2PRp1qkf5tKxc
         YiiQsj1bVRTddE19BmydYhu+969S2PAfuvHPdzlftmSAdNdQnoPoAxP9FILEe597Idbh
         YEMgDOfhyToI7SC0+vfx9OGzZFStil4RtDNWH1npmxWi+l0Mayl4+cizg3tXaVyJ1CbD
         Vu5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o17si1296059qtk.203.2019.06.27.02.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 02:39:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 889F081E0A;
	Thu, 27 Jun 2019 09:38:59 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (dhcp-192-180.str.redhat.com [10.33.192.180])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 507835C1B4;
	Thu, 27 Jun 2019 09:38:46 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Martin <Dave.Martin@arm.com>,  Yu-cheng Yu <yu-cheng.yu@intel.com>,
  X86 ML <x86@kernel.org>,  "H. Peter Anvin" <hpa@zytor.com>,  Thomas
 Gleixner <tglx@linutronix.de>,  Ingo Molnar <mingo@redhat.com>,  LKML
 <linux-kernel@vger.kernel.org>,  "open list\:DOCUMENTATION"
 <linux-doc@vger.kernel.org>,  Linux-MM <linux-mm@kvack.org>,  linux-arch
 <linux-arch@vger.kernel.org>,  Linux API <linux-api@vger.kernel.org>,
  Arnd Bergmann <arnd@arndb.de>,  Balbir Singh <bsingharora@gmail.com>,
  Cyrill Gorcunov <gorcunov@gmail.com>,  Dave Hansen
 <dave.hansen@linux.intel.com>,  Eugene Syromiatnikov <esyr@redhat.com>,
  "H.J. Lu" <hjl.tools@gmail.com>,  Jann Horn <jannh@google.com>,  Jonathan
 Corbet <corbet@lwn.net>,  Kees Cook <keescook@chromium.org>,  Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>,  Oleg
 Nesterov <oleg@redhat.com>,  Pavel Machek <pavel@ucw.cz>,  Peter Zijlstra
 <peterz@infradead.org>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Szabolcs Nagy <szabolcs.nagy@arm.com>,
  libc-alpha <libc-alpha@sourceware.org>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
	<20190502111003.GO3567@e103592.cambridge.arm.com>
	<CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
Date: Thu, 27 Jun 2019 11:38:45 +0200
In-Reply-To: <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
	(Andy Lutomirski's message of "Wed, 26 Jun 2019 10:14:07 -0700")
Message-ID: <87ef3fweoq.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 27 Jun 2019 09:39:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Andy Lutomirski:

> Also, I don't think there's any actual requirement that the upstream
> kernel recognize existing CET-enabled RHEL 8 binaries as being
> CET-enabled.  I tend to think that RHEL 8 jumped the gun here.

The ABI was supposed to be finalized and everyone involved thought it
had been reviewed by the GNU gABI community and other interested
parties.  It had been included in binutils for several releases.

From my point of view, the kernel is just a consumer of the ABI.  The
kernel would not change an instruction encoding if it doesn't like it
for some reason, either.

> While the upstream kernel should make some reasonble effort to make
> sure that RHEL 8 binaries will continue to run, I don't see why we
> need to go out of our way to keep the full set of mitigations
> available for binaries that were developed against a non-upstream
> kernel.

They were developed against the ABI specification.

I do not have a strong opinion what the kernel should do going forward.
I just want to make clear what happened.

Thanks,
Florian

