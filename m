Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5596B6E07
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 10:52:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w19-v6so2081501pfa.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 07:52:23 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e1-v6si19474183pgo.325.2018.09.04.07.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 07:52:22 -0700 (PDT)
Message-ID: <1536072478.12366.2.camel@intel.com>
Subject: Re: [RFC PATCH v3 00/24] Control Flow Enforcement: Shadow Stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 04 Sep 2018 07:47:58 -0700
In-Reply-To: <20180902081350.GF28695@350D>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180902081350.GF28695@350D>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Sun, 2018-09-02 at 18:13 +1000, Balbir Singh wrote:
> On Thu, Aug 30, 2018 at 07:38:40AM -0700, Yu-cheng Yu wrote:
> > 
> > The previous version of CET patches can be found in the following
> > link.
> > 
> > A  https://lkml.org/lkml/2018/7/10/1031
> > 
> > Summary of changes from v2:
> > 
> > A  Move Shadow Stack page fault handling logic to arch/x86.
> > A  Update can_follow_write_pte/pmd; move logic to arch/x86.
> > A  Fix problems in WRUSS in-line assembly.
> > A  Fix issues in ELF parser.
> > A  Split out IBT/PTRACE patches to a second set.
> > A  Other small fixes.
> > 
> Quick question -- is there a simulator or some other way you've
> been testing this? Just curious, if it's possible to run these
> patches or just a review and internal hardware/simulator where
> they are run and posted
> 
> Balbir Singh.

Currently only for review.

Yu-cheng
