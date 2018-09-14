Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3DD58E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 17:21:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s77-v6so4539545pgs.2
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 14:21:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n2-v6si8597180pgu.103.2018.09.14.14.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 14:21:41 -0700 (PDT)
Message-ID: <1536959832.12990.34.camel@intel.com>
Subject: Re: [RFC PATCH v3 05/24] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 14 Sep 2018 14:17:12 -0700
In-Reply-To: <20180830203948.GB1936@amd>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-6-yu-cheng.yu@intel.com> <20180830203948.GB1936@amd>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-08-30 at 22:39 +0200, Pavel Machek wrote:
> Hi!
> 
> > 
> > diff --git a/Documentation/admin-guide/kernel-parameters.txt
> > b/Documentation/admin-guide/kernel-parameters.txt
> > index 9871e649ffef..b090787188b4 100644
> > --- a/Documentation/admin-guide/kernel-parameters.txt
> > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > @@ -2764,6 +2764,12 @@
> > A 			noexec=on: enable non-executable mappings (default)
> > A 			noexec=off: disable non-executable mappings
> > A 
> > +	no_cet_ibt	[X86-64] Disable indirect branch tracking for
> > user-mode
> > +			applications
> > +
> > +	no_cet_shstk	[X86-64] Disable shadow stack support for user-
> > mode
> > +			applications
> Hmm, not too consistent with "nosmap" below. Would it make sense to
> have cet=on/off/ibt/shstk instead?

We also have noxsave, noxsaveopt, noxsaves, etc. A This style is more decisive?
If "cet=" is preferred, we can change it later?

Yu-cheng
