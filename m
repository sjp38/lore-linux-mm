Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0319BC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 22:55:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B867C2067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 22:55:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ywdw8i9N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B867C2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5577F6B0270; Tue, 13 Aug 2019 18:55:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E0DC6B0271; Tue, 13 Aug 2019 18:55:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A72C6B0272; Tue, 13 Aug 2019 18:55:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 11D006B0270
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 18:55:23 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A91278248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:55:22 +0000 (UTC)
X-FDA: 75818912484.16.car77_862fd8aaaa34a
X-HE-Tag: car77_862fd8aaaa34a
X-Filterd-Recvd-Size: 3815
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:55:22 +0000 (UTC)
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C26FC20843
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:55:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565736921;
	bh=+rrGnvdcanVtNKSBWoGJHi/njpfEfmBbO4E1AUigxgg=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=ywdw8i9NOLTIIMCBL4r7dwTOGtr9jQVBQm2Nfi4QSKZ5TDuLbpD9BYu+MoNU50rde
	 W1tfa4sGxkMsyAhZ8YrFO5xzfxyA9tQ1NJMN+KFszGDWDnu3nYJ5D8+ayQf/onHMht
	 XUrwBquLBtXbY8oQ8Evp9cZErtU2KDJXP2HM3BiQ=
Received: by mail-wm1-f44.google.com with SMTP id l2so2807171wmg.0
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:55:20 -0700 (PDT)
X-Gm-Message-State: APjAAAX2SA/EEC7xlB8wKOeiaZ92xSCpo1Cl3I+9TLNWJsA8ufd4GEfN
	A44CPvqiWxVudY2D//yPmba4QPRmiGcWwNZlYW5tmw==
X-Google-Smtp-Source: APXvYqz81rhcDjLrUXa949/jjm55ToItN38xIeCcUB+xCMtSJjaFWmN9F1yAoi+Z2N937R71Fz0pHZpiJ2OikJCF6K0=
X-Received: by 2002:a05:600c:24cf:: with SMTP id 15mr5069335wmu.76.1565736919249;
 Tue, 13 Aug 2019 15:55:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190813205225.12032-1-yu-cheng.yu@intel.com> <20190813205225.12032-16-yu-cheng.yu@intel.com>
In-Reply-To: <20190813205225.12032-16-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 13 Aug 2019 15:55:07 -0700
X-Gmail-Original-Message-ID: <CALCETrVKbqzivPfUOiGi5efHUpEsfPkNzP0CrmAZzcwUgf7quA@mail.gmail.com>
Message-ID: <CALCETrVKbqzivPfUOiGi5efHUpEsfPkNzP0CrmAZzcwUgf7quA@mail.gmail.com>
Subject: Re: [PATCH v8 15/27] mm: Handle shadow stack page fault
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 2:02 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> When a task does fork(), its shadow stack (SHSTK) must be duplicated
> for the child.  This patch implements a flow similar to copy-on-write
> of an anonymous page, but for SHSTK.
>
> A SHSTK PTE must be RO and dirty.  This dirty bit requirement is used
> to effect the copying.  In copy_one_pte(), clear the dirty bit from a
> SHSTK PTE to cause a page fault upon the next SHSTK access.  At that
> time, fix the PTE and copy/re-use the page.

Is using VM_SHSTK and special-casing all of this really better than
using a special mapping or other pseudo-file-backed VMA and putting
all the magic in the vm_operations?

--Andy

