Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F054E6B025F
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:51:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b85so1820486pfj.22
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 00:51:48 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c87si3224984pfk.441.2017.10.26.00.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 00:51:48 -0700 (PDT)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com [209.85.214.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A48EA21959
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 07:51:47 +0000 (UTC)
Received: by mail-it0-f50.google.com with SMTP id y15so4175481ita.4
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 00:51:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1507089272-32733-3-git-send-email-ricardo.neri-calderon@linux.intel.com>
References: <1507089272-32733-1-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <1507089272-32733-3-git-send-email-ricardo.neri-calderon@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 26 Oct 2017 00:51:25 -0700
Message-ID: <CALCETrUced9TVsMQ=cjFfDuDfLQsZWu0GOoRCmHn4PsSwrfOdw@mail.gmail.com>
Subject: Re: [PATCH v9 02/29] x86/boot: Relocate definition of the initial
 state of CR0
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Liang Z Li <liang.z.li@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "Neri, Ricardo" <ricardo.neri@intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 3, 2017 at 8:54 PM, Ricardo Neri
<ricardo.neri-calderon@linux.intel.com> wrote:
> Both head_32.S and head_64.S utilize the same value to initialize the
> control register CR0. Also, other parts of the kernel might want to access
> this initial definition (e.g., emulation code for User-Mode Instruction
> Prevention uses this state to provide a sane dummy value for CR0 when
> emulating the smsw instruction). Thus, relocate this definition to a
> header file from which it can be conveniently accessed.

Reviewed-by: Andy Lutomirski <luto@kernel.org>

with the slight caveat that I think it might be a wee bit better if
UMIP emulation used a separate define UMIP_REPORTED_CR0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
