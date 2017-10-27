Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90EFB6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 15:03:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v78so5464523pfk.8
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 12:03:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n13si5320592pgc.433.2017.10.27.12.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 12:03:29 -0700 (PDT)
Date: Fri, 27 Oct 2017 12:02:19 -0700
From: Ricardo Neri <ricardo.neri-calderon@linux.intel.com>
Subject: Re: [PATCH v9 02/29] x86/boot: Relocate definition of the initial
 state of CR0
Message-ID: <20171027190219.GA7057@voyager>
References: <1507089272-32733-1-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <1507089272-32733-3-git-send-email-ricardo.neri-calderon@linux.intel.com>
 <CALCETrUced9TVsMQ=cjFfDuDfLQsZWu0GOoRCmHn4PsSwrfOdw@mail.gmail.com>
 <20171026090045.GA6438@nazgul.tnic>
 <CALCETrXw2r-HD+9SwT0ndRVX2YR-_g6BKEfDd6i0ci5q_Z4S4Q@mail.gmail.com>
 <20171026125513.GB12068@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026125513.GB12068@nazgul.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Masami Hiramatsu <mhiramat@kernel.org>, Huang Rui <ray.huang@amd.com>, Jiri Slaby <jslaby@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Vlastimil Babka <vbabka@suse.cz>, Chen Yucong <slaoub@gmail.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Shuah Khan <shuah@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "Neri, Ricardo" <ricardo.neri@intel.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 26, 2017 at 02:55:13PM +0200, Borislav Petkov wrote:
> On Thu, Oct 26, 2017 at 02:02:02AM -0700, Andy Lutomirski wrote:
> > I'm assuming that UMIP_REPORTED_CR0 will never change.  If CR0 gets a
> > new field that we set some day, then I assume that CR0_STATE would add
> > that bit but UMIP_REPORTED_CR0 would not.
> 
> Yeah, let's do that when it is actually needed.

Thanks Andy! I reasoned that for UMIP could report CR0_STATE a value that
is already revealed in the source code. Thus, if CR0 ever changes at run
time, an attacker could only see what is set programmatically.

BR,

Ricardo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
