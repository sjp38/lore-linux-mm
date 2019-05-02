Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D80C04AAA
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:54:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C46A520675
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:54:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C46A520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5091C6B0003; Thu,  2 May 2019 11:54:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BBF26B0006; Thu,  2 May 2019 11:54:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A89C6B0007; Thu,  2 May 2019 11:54:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04E046B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:54:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t16so1418409pgv.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:54:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aZlDYSUhtJI5SI6ikbxNWyvb2x65XVi5kzB2glnT9v0=;
        b=VMKgSJ3YgC/NSd7uLa1Y8xQSNI0XhXaj9AWM0vwWsfNLjJaQOH9JXdQj4jEG79auLE
         33ZNyXB1wMVe9vqtOFIdtC5b6+2+AYwvF/XMFjDYjCziT34vECjomKyC+NFsHGImOCBL
         UsOCYBvsk7xmbVqO52o7m5JFG3uVihy8bdhtapIRjxqmode5g6keilZVT83nxMtr26O+
         Q2TgN49dSbpd9bMHJMFp0HDZatbQCn/PZp6ZekIP19i6U8sxlF5vnjv2kPY6c4bN8LRx
         McZ8iK7Y9A4MHr+B8sprhsQheYKvGz0PnBf9kTDQlfXRHK7qcbhRdLFvN6m0ofE0M0GG
         b5Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV+bTMyw9NVwM1qpTMCw5gZkdRnCaNjT6tM9VTIHccni848y19l
	5+4xLlU6i7XyGCAAMQtw38/t5fdEOPLnqOnlplXM/v16we76+fi2NqEXXjIsBA7W0bdhV91s2w5
	Cq6c/sLBUZfDBEWNV/YW9PLm567u/V4xxbUpWCMpG/OSfF8b54OA8ry18/obPQSuOFw==
X-Received: by 2002:a63:445d:: with SMTP id t29mr4729252pgk.303.1556812476514;
        Thu, 02 May 2019 08:54:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPSxoasw+/YGBUVapoJLbqKr2737qE9nWUB7B97Zb/pZNGCYAXP6F+3QYX7n0pmD/NZOco
X-Received: by 2002:a63:445d:: with SMTP id t29mr4729175pgk.303.1556812475450;
        Thu, 02 May 2019 08:54:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556812475; cv=none;
        d=google.com; s=arc-20160816;
        b=RbwgLwcdwq5+IlAU7OnEEoMfsGXKnUo/mLYBBjFgQcOf9UeNttW+o2OJdHLePCq4wZ
         yynvfPpReP2w2JKFV7LxND0ujTUFTtHmZfp0sCi0mbd+OkPr8GWJSnRgWJjIsX1rOu34
         wKFr7+KVX/25dC5k0FpWseZViGJSrAetmInrq1FfuZNFU0JdvOT5loMqjr21WldgX4tA
         msLoXIKiUdRDSYtVMXkkcD+SdyhMylrinIwhSr8zXaEfy18xuJ0XxyU/Fp1+AND/3CMa
         T+DI0WjHINLuQonPg0H7R3+SHxjOGE/Ra1YRvFz/xzmY3l0MDmSFbY3lwcYO0RfJ+XXK
         hmAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=aZlDYSUhtJI5SI6ikbxNWyvb2x65XVi5kzB2glnT9v0=;
        b=SXt40WwWrAv3aGudZu90wPjTlA5UPnRrU7of7PDTJi2hXSzf4OwwSkiT90bASVTeiq
         CrB7GnJNnm8THJQ3lCFGu7WPsptbmQ6yqwyw+5IdQ73zHYgkAq1p19LqAGDlVhWU4Wku
         bKFDThroE5VjA5v9L/YMYermcRsIl0fBPhXejuIC1tDmwuM+d0TQUPqC4PW59jWSz9pw
         O2C5yXWs3T1VqS5s7Il2SuksWu6aV41MX91BZ4Pque2SPSUunP5H/qchHuTtwxwYKVyW
         M0FIG78DZGNpYGc1ETZXCeIu0EDh4aCma0SFr5ejqhI5x6uf80Z8fskz7Owr65FnzWHv
         qgsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z8si41441789pgp.185.2019.05.02.08.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 08:54:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 May 2019 08:54:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,422,1549958400"; 
   d="scan'208";a="320874382"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga005.jf.intel.com with ESMTP; 02 May 2019 08:54:33 -0700
Message-ID: <5b2c6cee345e00182e97842ae90c02cdcd830135.camel@intel.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Szabolcs Nagy <szabolcs.nagy@arm.com>,
 libc-alpha@sourceware.org
Date: Thu, 02 May 2019 08:47:06 -0700
In-Reply-To: <20190502111003.GO3567@e103592.cambridge.arm.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
	 <20190502111003.GO3567@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-05-02 at 12:10 +0100, Dave Martin wrote:
> On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > An ELF file's .note.gnu.property indicates features the executable file
> > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > GNU_PROPERTY_X86_FEATURE_1_SHSTK.

[...]
> A couple of questions before I look in more detail:
> 
> 1) Can we rely on PT_GNU_PROPERTY being present in the phdrs to describe
> the NT_GNU_PROPERTY_TYPE_0 note?  If so, we can avoid trying to parse
> irrelevant PT_NOTE segments.

Some older linkers can create multiples of NT_GNU_PROPERTY_TYPE_0.  The code
scans all PT_NOTE segments to ensure there is only one NT_GNU_PROPERTY_TYPE_0. 
If there are multiples, then all are considered invalid.

> 
> 
> 2) Are there standard types for things like the program property header?
> If not, can we add something in elf.h?  We should try to coordinate with
> libc on that.  Something like
> 
> typedef __u32 Elf_Word;
> 
> typedef struct {
> 	Elf_Word pr_type;
> 	Elf_Word pr_datasz;
> } Elf_Gnu_Prophdr;
> 
> (i.e., just the header part from [1], with a more specific name -- which
> I just made up).

Yes, I will fix that.

[...]
> 3) It looks like we have to go and re-parse all the notes for every
> property requested by the arch code.

As explained above, it is necessary to scan all PT_NOTE segments.  But there
should be only one NT_GNU_PROPERTY_TYPE_0 in an ELF file.  Once that is found,
perhaps we can store it somewhere, or call into the arch code as you mentioned
below.  I will look into that.

> 
> For now there is only one property requested anyway, so this is probably
> not too bad.  But could we flip things around so that we have some
> CONFIG_ARCH_WANTS_ELF_GNU_PROPERTY (say), and have the ELF core code
> call into the arch backend for each property found?
> 
> The arch could provide some hook
> 
> 	int arch_elf_has_gnu_property(const Elf_Gnu_Prophdr *prop,
> 					const void *data);
> 
> to consume the properties as they are found.
> 
> This would effectively replace the arch_setup_property() hook you
> currently have.
> 
> Cheers
> ---Dave
> 
> [1] https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI

