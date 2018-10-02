Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2CD6B000E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 12:39:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s24-v6so3264658plp.12
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 09:39:34 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h15-v6si15365790pgn.389.2018.10.02.09.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 09:39:33 -0700 (PDT)
Subject: Re: [RFC PATCH v4 02/27] x86/fpu/xstate: Change some names to
 separate XSAVES system and user states
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-3-yu-cheng.yu@intel.com>
 <20181002152903.GB29601@zn.tnic>
 <ba13d643c21de8e1e01a8d528457fb5dd82c42aa.camel@intel.com>
 <498c8824-9255-96be-71c2-3ebfa684a9d3@linux.intel.com>
 <20181002163736.GD29601@zn.tnic>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6859a180-8973-e794-7ac4-1ac8f0e1c709@linux.intel.com>
Date: Tue, 2 Oct 2018 09:39:31 -0700
MIME-Version: 1.0
In-Reply-To: <20181002163736.GD29601@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 10/02/2018 09:37 AM, Borislav Petkov wrote:
> This patch's commit message is not even close. So I'd very much
> appreciate a more verbose explanation, even if it repeats itself at
> places.

Yep, totally agree.
