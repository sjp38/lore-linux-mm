Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DB6FC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4229F2084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:52:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4229F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 964256B0003; Wed, 14 Aug 2019 12:52:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 913026B0005; Wed, 14 Aug 2019 12:52:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827FA6B0006; Wed, 14 Aug 2019 12:52:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD146B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:52:08 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 09076181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:52:08 +0000 (UTC)
X-FDA: 75821625936.27.mind45_4cbc82e2a8223
X-HE-Tag: mind45_4cbc82e2a8223
X-Filterd-Recvd-Size: 2760
Received: from mga05.intel.com (mga05.intel.com [192.55.52.43])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:52:07 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Aug 2019 09:52:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,386,1559545200"; 
   d="scan'208";a="260559319"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga001.jf.intel.com with ESMTP; 14 Aug 2019 09:52:02 -0700
Message-ID: <c7731c682b55ec882ad3d4ea11ad7a823dcaae8f.camel@intel.com>
Subject: Re: [PATCH v8 11/27] x86/mm: Introduce _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>,  Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, 
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,  Dave Martin
 <Dave.Martin@arm.com>
Date: Wed, 14 Aug 2019 09:42:23 -0700
In-Reply-To: <dac2d62b-9045-4767-87dd-eac12e7abafd@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-12-yu-cheng.yu@intel.com>
	 <dac2d62b-9045-4767-87dd-eac12e7abafd@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-13 at 16:02 -0700, Dave Hansen wrote:
[...]
> Please also reconcile the supervisor XSAVE portion of your patches with
> the ones that Fenghua has been sending around.  I've given quite a bit
> of feedback to improve those.  Please consolidate and agree on a common
> set of patches with him.

XSAVES supervisor is now a six-patch set.  Maybe we can make it a separate
series?  I will consolidate and send it out.

Yu-cheng

