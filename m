Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 222946B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 12:26:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id v4-v6so3207969plz.21
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 09:26:21 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z5-v6si15696744pgf.561.2018.10.02.09.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 09:26:19 -0700 (PDT)
Message-ID: <ba13d643c21de8e1e01a8d528457fb5dd82c42aa.camel@intel.com>
Subject: Re: [RFC PATCH v4 02/27] x86/fpu/xstate: Change some names to
 separate XSAVES system and user states
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 02 Oct 2018 09:21:18 -0700
In-Reply-To: <20181002152903.GB29601@zn.tnic>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-3-yu-cheng.yu@intel.com>
	 <20181002152903.GB29601@zn.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-10-02 at 17:29 +0200, Borislav Petkov wrote:
> On Fri, Sep 21, 2018 at 08:03:26AM -0700, Yu-cheng Yu wrote:
> > To support XSAVES system states, change some names to distinguish
> > user and system states.
> 
> I don't understand what the logic here is. SDM says:
> 
> XSAVESa??Save Processor Extended States Supervisor
> 
> the stress being on "Supervisor" - why does it need to be renamed to
> "system" now?
> 

Good point.  However, "system" is more indicative; CET states are per-task and
not "Supervisor".  Do we want to go back to "Supervisor" or add comments?

Yu-cheng
