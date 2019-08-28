Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63448C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 15:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29F3722CF5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 15:07:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29F3722CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBBBF6B0008; Wed, 28 Aug 2019 11:07:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C92FF6B000C; Wed, 28 Aug 2019 11:07:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5B1A6B000E; Wed, 28 Aug 2019 11:07:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 951176B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:07:03 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 40BEE824CA16
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:07:03 +0000 (UTC)
X-FDA: 75872164326.15.plate71_779bf2c75e601
X-HE-Tag: plate71_779bf2c75e601
X-Filterd-Recvd-Size: 4346
Received: from mga17.intel.com (mga17.intel.com [192.55.52.151])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:07:01 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Aug 2019 08:07:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,441,1559545200"; 
   d="scan'208";a="380429742"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga005.fm.intel.com with ESMTP; 28 Aug 2019 08:06:59 -0700
Message-ID: <29e6afa9cd7a7b0069ec6b999a2830cbbbe50a56.camel@intel.com>
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
Date: Wed, 28 Aug 2019 07:57:41 -0700
In-Reply-To: <20190828070308.GJ2332@hirez.programming.kicks-ass.net>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-12-yu-cheng.yu@intel.com>
	 <20190823140233.GC2332@hirez.programming.kicks-ass.net>
	 <6c3dc33e16c8bbb6d45c0a6ec7c684de197fa065.camel@intel.com>
	 <20190828070308.GJ2332@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-28 at 09:03 +0200, Peter Zijlstra wrote:
> On Tue, Aug 27, 2019 at 03:37:12PM -0700, Yu-cheng Yu wrote:
> > On Fri, 2019-08-23 at 16:02 +0200, Peter Zijlstra wrote:
> > > On Tue, Aug 13, 2019 at 01:52:09PM -0700, Yu-cheng Yu wrote:
> > > 
> > > > +static inline pte_t pte_move_flags(pte_t pte, pteval_t from, pteval_t
> > > > to)
> > > > +{
> > > > +	if (pte_flags(pte) & from)
> > > > +		pte = pte_set_flags(pte_clear_flags(pte, from), to);
> > > > +	return pte;
> > > > +}
> > > 
> > > Aside of the whole conditional thing (I agree it would be better to have
> > > this unconditionally); the function doesn't really do as advertised.
> > > 
> > > That is, if @from is clear, it doesn't endeavour to make sure @to is
> > > also clear.
> > > 
> > > Now it might be sufficient, but in that case it really needs a comment
> > > and or different name.
> > > 
> > > An implementation that actually moves the bit is something like:
> > > 
> > > 	pteval_t a,b;
> > > 
> > > 	a = native_pte_value(pte);
> > > 	b = (a >> from_bit) & 1;
> > > 	a &= ~((1ULL << from_bit) | (1ULL << to_bit));
> > > 	a |= b << to_bit;
> > > 	return make_native_pte(a);
> > 
> > There can be places calling pte_wrprotect() on a PTE that is already RO +
> > DIRTY_SW.  Then in pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW) we do
> > not
> >  want to clear _PAGE_DIRTY_SW.  But, I will look into this and make it more
> > obvious.
> 
> Well, then the name 'move' is just wrong, because that is not the
> semantics you're looking for.
> 
> So the thing is; if you provide a generic function that 'munges' two
> bits, then it's name had better be accurate. But AFAICT you only ever
> used this for the DIRTY bits, so it might be better to have a function
> specifically for that and with a comment that spells out the exact
> semantics and reasons for them.

Yes, I will work on that.

Yu-cheng

