Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B664FC0650F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:08:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64493205C9
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:08:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64493205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D842D6B000C; Wed, 14 Aug 2019 04:07:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D34A06B0270; Wed, 14 Aug 2019 04:07:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71D36B0271; Wed, 14 Aug 2019 04:07:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id A483C6B000C
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:07:59 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5765C181AC9B4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:07:59 +0000 (UTC)
X-FDA: 75820305078.26.worm76_b7570f36cf06
X-HE-Tag: worm76_b7570f36cf06
X-Filterd-Recvd-Size: 3053
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:07:58 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 53C9C31499;
	Wed, 14 Aug 2019 08:07:57 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (dhcp-192-200.str.redhat.com [10.33.192.200])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4F4B4413C;
	Wed, 14 Aug 2019 08:07:47 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Thomas Gleixner
 <tglx@linutronix.de>,  Ingo Molnar <mingo@redhat.com>,
  linux-kernel@vger.kernel.org,  linux-doc@vger.kernel.org,
  linux-mm@kvack.org,  linux-arch@vger.kernel.org,
  linux-api@vger.kernel.org,  Arnd Bergmann <arnd@arndb.de>,  Andy
 Lutomirski <luto@amacapital.net>,  Balbir Singh <bsingharora@gmail.com>,
  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov <gorcunov@gmail.com>,
  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene Syromiatnikov
 <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann Horn
 <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Peter Zijlstra <peterz@infradead.org>,  Randy
 Dunlap <rdunlap@infradead.org>,  "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v8 01/27] Documentation/x86: Add CET description
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	<20190813205225.12032-2-yu-cheng.yu@intel.com>
Date: Wed, 14 Aug 2019 10:07:45 +0200
In-Reply-To: <20190813205225.12032-2-yu-cheng.yu@intel.com> (Yu-cheng Yu's
	message of "Tue, 13 Aug 2019 13:51:59 -0700")
Message-ID: <87tvakgofi.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 14 Aug 2019 08:07:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Yu-cheng Yu:

> +ENDBR
> +    The compiler inserts an ENDBR at all valid branch targets.  Any
> +    CALL/JMP to a target without an ENDBR triggers a control
> +    protection fault.

Is this really correct?  I think ENDBR is needed only for indirect
branch targets where the jump/call does not have a NOTRACK prefix.  In
general, for security hardening, it seems best to minimize the number of
ENDBR instructions, and use NOTRACK for indirect jumps which derive the
branch target address from information that cannot be modified.

Thanks,
Florian

