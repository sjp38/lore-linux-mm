Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5BC16B026F
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 18:00:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u68-v6so1775620qku.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:00:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l123-v6si4560864qke.323.2018.07.23.15.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 15:00:05 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:59:58 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
Message-ID: <20180723215958.jozblzq4sv7gp7uj@treble>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <20180723140925.GA4285@amd>
 <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
 <20180723213830.GA4632@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180723213830.GA4632@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?utf-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Mon, Jul 23, 2018 at 11:38:30PM +0200, Pavel Machek wrote:
> But for now I'd like at least "global" option of turning pti on/off
> during runtime for benchmarking. Let me see...
> 
> Something like this, or is it going to be way more complex? Does
> anyone have patch by chance?

RHEL/CentOS has a global PTI enable/disable, which uses stop_machine().

-- 
Josh
