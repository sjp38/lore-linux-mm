Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 051586B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 05:02:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z11so1951285pfk.23
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 02:02:25 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r9si3296665pfg.482.2017.10.26.02.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 02:02:25 -0700 (PDT)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com [209.85.214.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 887A82195A
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:02:24 +0000 (UTC)
Received: by mail-it0-f50.google.com with SMTP id n195so13105405itg.1
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 02:02:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171026090045.GA6438@nazgul.tnic>
References: <1507089272-32733-1-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <1507089272-32733-3-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <CALCETrUced9TVsMQ=cjFfDuDfLQsZWu0GOoRCmHn4PsSwrfOdw@mail.gmail.com> <20171026090045.GA6438@nazgul.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 26 Oct 2017 02:02:02 -0700
Message-ID: <CALCETrXw2r-HD+9SwT0ndRVX2YR-_g6BKEfDd6i0ci5q_Z4S4Q@mail.gmail.com>
Subject: Re: [PATCH v9 02/29] x86/boot: Relocate definition of the initial
 state of CR0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Liang Z Li <liang.z.li@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "Neri, Ricardo" <ricardo.neri@intel.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 26, 2017 at 2:00 AM, Borislav Petkov <bp@suse.de> wrote:
> On Thu, Oct 26, 2017 at 12:51:25AM -0700, Andy Lutomirski wrote:
>> with the slight caveat that I think it might be a wee bit better if
>> UMIP emulation used a separate define UMIP_REPORTED_CR0.
>
> Why, do you see CR0_STATE and UMIP_REPORTED_CR0 becoming different at
> some point?

I'm assuming that UMIP_REPORTED_CR0 will never change.  If CR0 gets a
new field that we set some day, then I assume that CR0_STATE would add
that bit but UMIP_REPORTED_CR0 would not.

>
> --
> Regards/Gruss,
>     Boris.
>
> SUSE Linux GmbH, GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton=
, HRB 21284 (AG N=C3=BCrnberg)
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
