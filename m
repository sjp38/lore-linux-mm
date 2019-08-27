Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E64C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 22:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4BDD206BB
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 22:46:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4BDD206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626906B0006; Tue, 27 Aug 2019 18:46:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D6D16B0008; Tue, 27 Aug 2019 18:46:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 512F96B000A; Tue, 27 Aug 2019 18:46:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED506B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:46:38 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C47CE52BB
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:46:37 +0000 (UTC)
X-FDA: 75869693634.19.goose60_9117fe9024336
X-HE-Tag: goose60_9117fe9024336
X-Filterd-Recvd-Size: 3505
Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:46:36 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Aug 2019 15:46:31 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,439,1559545200"; 
   d="scan'208";a="192396943"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga002.jf.intel.com with ESMTP; 27 Aug 2019 15:46:30 -0700
Message-ID: <6c3dc33e16c8bbb6d45c0a6ec7c684de197fa065.camel@intel.com>
Subject: Re: [PATCH v8 11/27] x86/mm: Introduce _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>, Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,  Pavel Machek
 <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Tue, 27 Aug 2019 15:37:12 -0700
In-Reply-To: <20190823140233.GC2332@hirez.programming.kicks-ass.net>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-12-yu-cheng.yu@intel.com>
	 <20190823140233.GC2332@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-23 at 16:02 +0200, Peter Zijlstra wrote:
> On Tue, Aug 13, 2019 at 01:52:09PM -0700, Yu-cheng Yu wrote:
> 
> > +static inline pte_t pte_move_flags(pte_t pte, pteval_t from, pteval_t to)
> > +{
> > +	if (pte_flags(pte) & from)
> > +		pte = pte_set_flags(pte_clear_flags(pte, from), to);
> > +	return pte;
> > +}
> 
> Aside of the whole conditional thing (I agree it would be better to have
> this unconditionally); the function doesn't really do as advertised.
> 
> That is, if @from is clear, it doesn't endeavour to make sure @to is
> also clear.
> 
> Now it might be sufficient, but in that case it really needs a comment
> and or different name.
> 
> An implementation that actually moves the bit is something like:
> 
> 	pteval_t a,b;
> 
> 	a = native_pte_value(pte);
> 	b = (a >> from_bit) & 1;
> 	a &= ~((1ULL << from_bit) | (1ULL << to_bit));
> 	a |= b << to_bit;
> 	return make_native_pte(a);

There can be places calling pte_wrprotect() on a PTE that is already RO +
DIRTY_SW.  Then in pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW) we do not
 want to clear _PAGE_DIRTY_SW.  But, I will look into this and make it more
obvious.

Thanks,
Yu-cheng  

