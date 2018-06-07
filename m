Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B106D6B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:34:14 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 89-v6so5953020plb.18
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:34:14 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id ay2-v6si5007470plb.266.2018.06.07.13.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:34:13 -0700 (PDT)
Message-ID: <1528403461.5265.36.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 02/10] x86/cet: Introduce WRUSS instruction
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 13:31:01 -0700
In-Reply-To: <20180607184142.GJ12217@hirez.programming.kicks-ass.net>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-3-yu-cheng.yu@intel.com>
	 <CALCETrU45Cuzvfz3c1+-+7=9KS2N33Bpp1JqBtaGxhPo8U+Fqg@mail.gmail.com>
	 <20180607184142.GJ12217@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 20:41 +0200, Peter Zijlstra wrote:
> On Thu, Jun 07, 2018 at 09:40:02AM -0700, Andy Lutomirski wrote:
> > Peterz, isn't there some fancy better way we're supposed to handle the
> > error return these days?
> 
> Don't think so. I played with a few things but that never really went
> anywhere.
> 
> Also, both asm things look suspicously similar, it might make sense to
> share. Also, maybe do the instruction .byte sequence in a #define INSN
> or something.

I will fix that.
