Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65324C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:47:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A58420B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:47:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A58420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A18498E0005; Tue, 18 Jun 2019 08:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A1DB8E0001; Tue, 18 Jun 2019 08:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 842618E0005; Tue, 18 Jun 2019 08:47:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 607498E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:47:19 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so10810130qkl.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:47:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=opsNft9+oEt1EVUpsOi8KCqXxyz7DtkrAZDDZb/KD/8=;
        b=dVSau9go6P/a4QMDAIM1l9dHABl2JsTnip6dAE7LflbLDintji8FiqH+yab/8vIPI9
         FzilrN4VUy+RZhG8mqGTmNhrTAaM2a+2h9obecM50eesiwvqqK5bxNFlyskAs5iXdz+e
         4/ZhBVuGIR+URphT0ymKFbqHyYdzkn/A4LRmAEMRNavYRorxiJgxmaJBDUCRnHBWdAzJ
         8WydsGI3oUHlOJVD2q3cg+R3pXyRMbaeULVMxFx06dLU8fOPyZO4cX4E3J1Ur1DrYoYe
         URphQNF07TgDy3KJ7OG3EUSmAckNePk2gn0JPH+wJfnNivNMT66rGBZQfhUOsV2gvu0d
         oBNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWsrFN5oX6msLDsa2M8iwcVQ87nErLtywx3la6QAmF0gwmeDXv9
	uXD2VYB4uS0fAU5ynNdmxH+KAERcTuBFiA+pLohW1bht8apEGR9mtE6DKe/Dj4C5kZZpAOO2wYP
	ULVJzmmp2aZm1zAjONSKducNADXW7COD6YeydIlhKW6SDOy+ze8H2/kCz7hTG3u5GNw==
X-Received: by 2002:ac8:6b42:: with SMTP id x2mr94316222qts.92.1560862039199;
        Tue, 18 Jun 2019 05:47:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8ZlbCzZ1RiiLhDraSN1urV45A4mcjT/6eWLRUeehpHy9v3FTtnFoWsHgX4UAhlEuW4m44
X-Received: by 2002:ac8:6b42:: with SMTP id x2mr94316181qts.92.1560862038629;
        Tue, 18 Jun 2019 05:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560862038; cv=none;
        d=google.com; s=arc-20160816;
        b=ryV1wtWaa7A8nUMxvlHmRMZWPCn28UIF6VDpd/FNbQoCWppp52R9ffu8sqo5zWUmT/
         4fPY67SktCV+f+lcabMc2WKGvoHJmBuqLWlBh5E8bdxIwsKdcuTrWvW8H4L40AvJ+Ole
         jveyAMmLGFyw/PTFb9S2aKvJKpFmMqJs1uBLPSxF7avUSN2vv6zWJxByfUuLRlYxPpRN
         5zWVuCEJcqzhzbLnfOkzmDCf2wujshn4FH52D36710C7a5Vd0JZ/oXiQUKvxSGqS43Tr
         7IIwX8FVbPKVnz9sg5TMOOWWizhIK4QSo/uTJ/8/obtUSXTd1+gRF3opjq8IAzzyEYDF
         mEWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=opsNft9+oEt1EVUpsOi8KCqXxyz7DtkrAZDDZb/KD/8=;
        b=e2b8KLKZBkMpx1xk2cjfgtGyWOB3Nm3TTfav2mNxE3km9jmwGPJnzGpzlHX+7Lgu+g
         JaH07h0+mbFrdZZh6S+KKR1BOLvBP+HPTM3omEenIQHCdy81jWsa513R0mp1RW/yAUM1
         4CTnj3Ozde6Wd3DU1+8C4KCBNkUItOVKHFdaN4R3s+1+APLL12CI1npyJQ75v/asgXrm
         KU++abwYtRXLE1y4TfGhW1y7SbvpECGzb7JUhkAYcW+syTNJiJJdWaRaKa1U1v31Y+dt
         NVgdAQKZ5hlgLhKKZufxjEdYlXbTWTNX9cu0dMJ+dZVs49HbBfiTGYwP07vEAHTAPBeJ
         KjmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 141si9737199qke.43.2019.06.18.05.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 05:47:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 468E8C05B1CA;
	Tue, 18 Jun 2019 12:47:17 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (dhcp-192-180.str.redhat.com [10.33.192.180])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CFB6F36FA;
	Tue, 18 Jun 2019 12:47:01 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Martin <Dave.Martin@arm.com>,  Thomas Gleixner
 <tglx@linutronix.de>,  Yu-cheng Yu <yu-cheng.yu@intel.com>,
  x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Ingo Molnar
 <mingo@redhat.com>,  linux-kernel@vger.kernel.org,
  linux-doc@vger.kernel.org,  linux-mm@kvack.org,
  linux-arch@vger.kernel.org,  linux-api@vger.kernel.org,  Arnd Bergmann
 <arnd@arndb.de>,  Andy Lutomirski <luto@amacapital.net>,  Balbir Singh
 <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene
 Syromiatnikov <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann
 Horn <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an ELF file
References: <20190606200646.3951-23-yu-cheng.yu@intel.com>
	<20190607180115.GJ28398@e103592.cambridge.arm.com>
	<94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
	<87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	<20190611114109.GN28398@e103592.cambridge.arm.com>
	<031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	<20190612093238.GQ28398@e103592.cambridge.arm.com>
	<87imt4jwpt.fsf@oldenburg2.str.redhat.com>
	<alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
	<20190618091248.GB2790@e103592.cambridge.arm.com>
	<20190618124122.GH3419@hirez.programming.kicks-ass.net>
Date: Tue, 18 Jun 2019 14:47:00 +0200
In-Reply-To: <20190618124122.GH3419@hirez.programming.kicks-ass.net> (Peter
	Zijlstra's message of "Tue, 18 Jun 2019 14:41:22 +0200")
Message-ID: <87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 18 Jun 2019 12:47:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra:

> I'm not sure I read Thomas' comment like that. In my reading keeping the
> PT_NOTE fallback is exactly one of those 'fly workarounds'. By not
> supporting PT_NOTE only the 'fine' people already shit^Hpping this out
> of tree are affected, and we don't have to care about them at all.

Just to be clear here: There was an ABI document that required PT_NOTE
parsing.  The Linux kernel does *not* define the x86-64 ABI, it only
implements it.  The authoritative source should be the ABI document.

In this particularly case, so far anyone implementing this ABI extension
tried to provide value by changing it, sometimes successfully.  Which
makes me wonder why we even bother to mainatain ABI documentation.  The
kernel is just very late to the party.

Thanks,
Florian

