Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 654E36B026C
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:42:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u18-v6so21099219pfh.21
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 10:42:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e9-v6si25024976plk.130.2018.07.13.10.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 10:42:46 -0700 (PDT)
Message-ID: <1531503545.11680.4.camel@intel.com>
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 13 Jul 2018 10:39:05 -0700
In-Reply-To: <8bd46e0e-5418-0b22-d471-092d31c78320@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-19-yu-cheng.yu@intel.com>
	 <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com>
	 <1531436398.2965.18.camel@intel.com>
	 <46784af0-6fbb-522d-6acb-c6248e5e0e0d@linux.intel.com>
	 <167645aa-f1c7-bd6a-c7e0-2da317cbbaba@intel.com>
	 <55A0592D-0E8D-4BC5-BA4B-E82E92EEA36A@amacapital.net>
	 <66016722-9872-a3f9-f88b-37397f9b6979@intel.com>
	 <8bd46e0e-5418-0b22-d471-092d31c78320@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-07-12 at 21:18 -0700, Dave Hansen wrote:
> On 07/12/2018 09:16 PM, Dave Hansen wrote:
> > 
> > On 07/12/2018 07:21 PM, Andy Lutomirski wrote:
> > > 
> > > I am tempted to suggest that the whole series not be merged until
> > > there are actual docs. Ita??s not a fantastic precedent.
> > Do you mean Documentation or manpages, or are you talking about hardware
> > documentation?
> > https://software.intel.com/sites/default/files/managed/4d/2a/control-flow-enforcement-technology-preview.pdf
> Hit send too soon...
> 
> We do need manpages a well.A A If I had to do it for protection keys,
> everyone else has to suffer too. :)
> 
> Yu-cheng, I really do think selftests are a necessity before this gets
> merged.
> 

We already have some. A I will put those in patches.

Yu-cheng
