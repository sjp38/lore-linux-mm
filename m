Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDA56B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 18:07:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b9-v6so1294499pla.19
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:07:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p2-v6si10736819pli.289.2018.07.23.15.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 15:07:32 -0700 (PDT)
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <20180723140925.GA4285@amd>
 <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com>
 <20180723213830.GA4632@amd> <20180723215958.jozblzq4sv7gp7uj@treble>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f654c085-d07c-5047-0d59-e2f88b00e921@intel.com>
Date: Mon, 23 Jul 2018 15:07:13 -0700
MIME-Version: 1.0
In-Reply-To: <20180723215958.jozblzq4sv7gp7uj@treble>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>, Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On 07/23/2018 02:59 PM, Josh Poimboeuf wrote:
> On Mon, Jul 23, 2018 at 11:38:30PM +0200, Pavel Machek wrote:
>> But for now I'd like at least "global" option of turning pti on/off
>> during runtime for benchmarking. Let me see...
>>
>> Something like this, or is it going to be way more complex? Does
>> anyone have patch by chance?
> RHEL/CentOS has a global PTI enable/disable, which uses stop_machine().

Let's not forget PTI's NX-for-userspace in the kernel page tables.  That
provides Spectre V2 mitigation as well as Meltdown.
