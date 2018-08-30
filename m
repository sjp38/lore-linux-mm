Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 437A96B53C1
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 18:54:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so5781976pgs.15
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:54:15 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 13-v6si7981833pgp.563.2018.08.30.15.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 15:54:14 -0700 (PDT)
Message-ID: <1535669391.28781.7.camel@intel.com>
Subject: Re: [RFC PATCH v3 05/24] Documentation/x86: Add CET description
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 30 Aug 2018 15:49:51 -0700
In-Reply-To: <20180830203948.GB1936@amd>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-6-yu-cheng.yu@intel.com> <20180830203948.GB1936@amd>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

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
> > A 			noexec=on: enable non-executable mappings
> > (default)
> > A 			noexec=off: disable non-executable
> > mappings
> > A 
> > +	no_cet_ibt	[X86-64] Disable indirect branch
> > tracking for user-mode
> > +			applications
> > +
> > +	no_cet_shstk	[X86-64] Disable shadow stack support
> > for user-mode
> > +			applications
> Hmm, not too consistent with "nosmap" below. Would it make sense to
> have cet=on/off/ibt/shstk instead?
> 
> > 
> > +++ b/Documentation/x86/intel_cet.rst
> > @@ -0,0 +1,252 @@
> > +=========================================
> > +Control Flow Enforcement Technology (CET)
> > +=========================================
> > +
> > +[1] Overview
> > +============
> > +
> > +Control Flow Enforcement Technology (CET) provides protection
> > against
> > +return/jump-oriented programing (ROP) attacks.
> Can you add something like "It attempts to protect process from
> running arbitrary code even after attacker has control of its stack"
> -- for people that don't know what ROP is, and perhaps link to
> wikipedia explaining ROP or something...
> 
> > 
> > It can be implemented
> > +to protect both the kernel and applications.A A In the first phase,
> > +only the user-mode protection is implemented for the 64-bit
> > kernel.
> > +Thirty-two bit applications are supported under the compatibility
> 32-bit (for consistency).
> 
> Ok, so CET stops execution of malicious code before architectural
> effects are visible, correct? Does it prevent micro-architectural
> effects of the malicious code? (cache content would be one example;
> see Spectre).
> 
> > 
> > +[3] Application Enabling
> > +========================
> "Enabling CET in applications" ?
> 
> > 
> > +Signal
> > +------
> > +
> > +The main program and its signal handlers use the same
> > SHSTK.A A Because
> > +the SHSTK stores only return addresses, we can estimate a large
> > +enough SHSTK to cover the condition that both the program stack
> > and
> > +the sigaltstack run out.
> English? Is it estimate or is it large enough? "a large" -- "a"
> should
> be deleted AFAICT.
> A 

I will work on these, thanks!
