Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03A446B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 08:55:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b79so2357714pfk.9
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 05:55:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k87si3641425pfj.56.2017.10.26.05.55.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 05:55:17 -0700 (PDT)
Date: Thu, 26 Oct 2017 14:55:13 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH v9 02/29] x86/boot: Relocate definition of the initial
 state of CR0
Message-ID: <20171026125513.GB12068@nazgul.tnic>
References: <1507089272-32733-1-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <1507089272-32733-3-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <CALCETrUced9TVsMQ=cjFfDuDfLQsZWu0GOoRCmHn4PsSwrfOdw@mail.gmail.com>
 <20171026090045.GA6438@nazgul.tnic>
 <CALCETrXw2r-HD+9SwT0ndRVX2YR-_g6BKEfDd6i0ci5q_Z4S4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALCETrXw2r-HD+9SwT0ndRVX2YR-_g6BKEfDd6i0ci5q_Z4S4Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "Neri, Ricardo" <ricardo.neri@intel.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 26, 2017 at 02:02:02AM -0700, Andy Lutomirski wrote:
> I'm assuming that UMIP_REPORTED_CR0 will never change.  If CR0 gets a
> new field that we set some day, then I assume that CR0_STATE would add
> that bit but UMIP_REPORTED_CR0 would not.

Yeah, let's do that when it is actually needed.

Thx.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
