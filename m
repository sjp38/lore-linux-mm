Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45270C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:12:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0392020B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:12:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0392020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 745896B0010; Wed, 12 Jun 2019 15:12:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6176B0266; Wed, 12 Jun 2019 15:12:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BDE16B0269; Wed, 12 Jun 2019 15:12:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24AD86B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:12:05 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i3so10353554plb.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:12:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s00AAfCzMqnvlZ7R2AV8WRUEjG3KLNo+EF1uxi9WrvY=;
        b=hRDinY/fZQTQ+bh2VH/7nfSsio7K47rGX3WcaQS2m3XbeQA1x9NXU8We0O6g/2D31c
         GGOItk7s/2EXr95KxvAW6siE598Lj026k0lYOzxzMymhZVkaqNybyRcRpES1wE8lJLmj
         tVkdk51LsRkH0dKeuA5F0FzefOGYsulhfY6ZKfAWIk+rMuC9LI4iRns0pQm2ncyqsS2B
         qOnIzDE3Y8/31Zv5ZE78/uizPiMvXWSbu1n6PyNg8qig0NNvIamhbR75G6XNwyzR3F/6
         CGq/y/fALgEBuj3QDnS5V7HfwE5j54r+tKbFoMAS3ARdAazTVLCXxyvtfZFSSFG+f+6H
         JN/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVS1kHhDQQp4ZuT8ObVHJJLtkQ0rdly5akpWGcU9EzP7IoiLRiO
	fKKVxDXnooyqyJMRDZq3J2PhDN7IiLk5lc/mSAMFfG7HLGbMpBJKyX7G5t09A1qWZiyZbQ5SnCP
	wfYvYFdA9KK5cJJ3iUGhT4S4VwJa3aiuxODYnfPkf+ew6nYVuWah07QI/GojQalAyfA==
X-Received: by 2002:a62:fccd:: with SMTP id e196mr15469456pfh.53.1560366724804;
        Wed, 12 Jun 2019 12:12:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGJQz/GFbDbIg7KPhUgxbq7WQXIrXkc4TTIukg39EkWGtld2ATjzilfIaWBCEnqMAZXJ6z
X-Received: by 2002:a62:fccd:: with SMTP id e196mr15469400pfh.53.1560366723977;
        Wed, 12 Jun 2019 12:12:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560366723; cv=none;
        d=google.com; s=arc-20160816;
        b=TSZuA3bLxn3N0gwFgKnj90zKcAtiDLo2Mq0oPJWhZF1fRjvGyUGhMJXl33uuGHJ9ub
         tes+3hnNgOWtaQaT9aLN50C9T/kCMRVLvLODzZEmog7LXnatJDUsHO5px3JRRN/Q4VUU
         Vu/7RPICAz9lWyUMndDDDHRoSZP4cdrpVnEa01j8AaR/85VYggwoFOQo63U+9subjpau
         2iXBGh58qem9DANbT3SZlNhBlJWg/AhNYIJTTH578ZqLiqiyRVg8zKFXElTqsX0bg6+Z
         M1tnD71YYlrVbQKPs2RDPdduqEjbEZcX07tL8Jd7EQeavtumOqDYjQB61aRq1r0mY+mF
         iu1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=s00AAfCzMqnvlZ7R2AV8WRUEjG3KLNo+EF1uxi9WrvY=;
        b=wM4sgszokagc26nGy4AlXPoHDs1Rs4Cs+Lho7J4faUqka7zOsoXmuuz07afD50cwTw
         PywfPh/a5wy2a1lMXkoHSPZP25e9wI16MUFrjRxJ9NmWojnM9spHbrnLMVbLy434N8l6
         LU8BQtqaGaLYmSIDCxwm5/u/PzMAw1uR0vxIucFrnuGDnd72esXSoCFzHpN0b9//gwk7
         Xx/rG8LbGYnFxo9N3vcnAX7Ln28sQ7O20lbK2ht1djcryYVlmQiS2kKNRonjxYpVulUG
         WOaAJt+Xs67AXIZDpHI+bjjS0Ouy8Q7oEEGXnScdAOjiKHtrjPk08qkWLviFyS5ZfnfL
         EXRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o3si455677pll.53.2019.06.12.12.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 12:12:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 12:12:03 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga005.jf.intel.com with ESMTP; 12 Jun 2019 12:12:00 -0700
Message-ID: <b8fb6626a6ae415fac4d5daa86225e4c68d56673.camel@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Florian Weimer <fweimer@redhat.com>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>,  Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan
 Corbet <corbet@lwn.net>,  Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Date: Wed, 12 Jun 2019 12:04:01 -0700
In-Reply-To: <20190612093238.GQ28398@e103592.cambridge.arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-23-yu-cheng.yu@intel.com>
	 <20190607180115.GJ28398@e103592.cambridge.arm.com>
	 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
	 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	 <20190611114109.GN28398@e103592.cambridge.arm.com>
	 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	 <20190612093238.GQ28398@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-12 at 10:32 +0100, Dave Martin wrote:
> On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
> > On Tue, 2019-06-11 at 12:41 +0100, Dave Martin wrote:
> > > On Mon, Jun 10, 2019 at 07:24:43PM +0200, Florian Weimer wrote:
> > > > * Yu-cheng Yu:
> > > > 
> > > > > To me, looking at PT_GNU_PROPERTY and not trying to support anything
> > > > > is a
> > > > > logical choice.  And it breaks only a limited set of toolchains.
> > > > > 
> > > > > I will simplify the parser and leave this patch as-is for anyone who
> > > > > wants
> > > > > to
> > > > > back-port.  Are there any objections or concerns?
> > > > 
> > > > Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
> > > > the largest collection of CET-enabled binaries that exists today.
> > > 
> > > For clarity, RHEL is actively parsing these properties today?
> > > 
> > > > My hope was that we would backport the upstream kernel patches for CET,
> > > > port the glibc dynamic loader to the new kernel interface, and be ready
> > > > to run with CET enabled in principle (except that porting userspace
> > > > libraries such as OpenSSL has not really started upstream, so many
> > > > processes where CET is particularly desirable will still run without
> > > > it).
> > > > 
> > > > I'm not sure if it is a good idea to port the legacy support if it's not
> > > > part of the mainline kernel because it comes awfully close to creating
> > > > our own private ABI.
> > > 
> > > I guess we can aim to factor things so that PT_NOTE scanning is
> > > available as a fallback on arches for which the absence of
> > > PT_GNU_PROPERTY is not authoritative.
> > 
> > We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
> > version?) to PT_NOTE scanning?
> 
> For arm64, we can check for PT_GNU_PROPERTY and then give up
> unconditionally.
> 
> For x86, we would fall back to PT_NOTE scanning, but this will add a bit
> of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
> version doesn't tell you what ELF ABI a given executable conforms to.
> 
> Since this sounds like it's largely a distro-specific issue, maybe there
> could be a Kconfig option to turn the fallback PT_NOTE scanning on?

Yes, I will make it a Kconfig option.

Yu-cheng

