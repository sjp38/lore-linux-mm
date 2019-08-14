Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3712EC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:07:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05F68208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:07:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05F68208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A213E6B000A; Wed, 14 Aug 2019 12:07:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CF446B000C; Wed, 14 Aug 2019 12:07:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDEE6B000D; Wed, 14 Aug 2019 12:07:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 653CC6B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:07:01 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 20D602826
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:07:01 +0000 (UTC)
X-FDA: 75821512242.24.fang01_776938b605c23
X-HE-Tag: fang01_776938b605c23
X-Filterd-Recvd-Size: 2729
Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:07:00 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Aug 2019 09:06:59 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,385,1559545200"; 
   d="scan'208";a="184358026"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Aug 2019 09:06:58 -0700
Message-ID: <84fc1b3bb2dbcf52ca79cb1141a431e087f082b5.camel@intel.com>
Subject: Re: [PATCH v8 01/27] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Florian Weimer <fweimer@redhat.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan
 Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Wed, 14 Aug 2019 08:57:19 -0700
In-Reply-To: <87tvakgofi.fsf@oldenburg2.str.redhat.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-2-yu-cheng.yu@intel.com>
	 <87tvakgofi.fsf@oldenburg2.str.redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-14 at 10:07 +0200, Florian Weimer wrote:
> * Yu-cheng Yu:
> 
> > +ENDBR
> > +    The compiler inserts an ENDBR at all valid branch targets.  Any
> > +    CALL/JMP to a target without an ENDBR triggers a control
> > +    protection fault.
> 
> Is this really correct?  I think ENDBR is needed only for indirect
> branch targets where the jump/call does not have a NOTRACK prefix.

You are right.  I will fix the wording.

Yu-cheng

