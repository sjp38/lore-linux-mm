Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEA6D6B0275
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 11:29:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t10-v6so16500259pfh.0
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:29:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z1-v6si18787549plo.516.2018.07.11.08.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 08:29:30 -0700 (PDT)
Message-ID: <1531322749.13297.17.camel@intel.com>
Subject: Re: [RFC PATCH v2 05/27] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 08:25:49 -0700
In-Reply-To: <20180711082739.GA18919@amd>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-6-yu-cheng.yu@intel.com> <20180711082739.GA18919@amd>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 10:27 +0200, Pavel Machek wrote:
> On Tue 2018-07-10 15:26:17, Yu-cheng Yu wrote:
> > 
> > Explain how CET works and the no_cet_shstk/no_cet_ibt kernel
> > parameters.
> > 
> > 
> > --- /dev/null
> > +++ b/Documentation/x86/intel_cet.txt
> > @@ -0,0 +1,250 @@
> > +=========================================
> > +Control Flow Enforcement Technology (CET)
> > +=========================================
> We normally use .rst for this kind of formatted text.

I will change this to a .rst file.

> 
> 
> > 
> > +[6] The implementation of the SHSTK
> > +===================================
> > +
> > +SHSTK size
> > +----------
> > +
> > +A task's SHSTK is allocated from memory to a fixed size that can
> > +support 32 KB nested function calls; that is 256 KB for a 64-bit
> > +application and 128 KB for a 32-bit application.A A The system admin
> > +can change the default size.
> How does admin change that? We already have ulimit for stack size,
> should those be somehow tied together?
> 
> $ ulimit -a
> ...
> stack sizeA A A A A A A A A A A A A A (kbytes, -s) 8192
> 

We can do that. A This makes sense to me.

Yu-cheng
