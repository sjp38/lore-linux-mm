Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1656B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:03:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b9-v6so2209271edn.18
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 15:03:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9-v6si4026386edl.190.2018.07.24.15.03.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 15:03:02 -0700 (PDT)
Date: Wed, 25 Jul 2018 00:02:55 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
In-Reply-To: <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
Message-ID: <nycvar.YFH.7.76.1807242351500.997@cbobk.fhfr.pm>
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu> <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm> <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel@lists.xenproject.org, =?ISO-8859-2?Q?Kr=E8m=E1=F8?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, linux@dominikbrodowski.net, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jan Beulich <jbeulich@suse.com>, Arjan van de Ven <arjan@linux.intel.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?ISO-8859-15?Q?J=F6rg_Otte?= <jrg.otte@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, gnomes@lxorguk.ukuu.org.uk, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?ISO-8859-15?Q?Micka=EBlSala=FCn?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, gregkh@linux-foundation.org, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Jiri Olsa <jolsa@redhat.com>, arjan.van.de.ven@intel.com, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com

On Tue, 24 Jul 2018, Srivatsa S. Bhat wrote:

> However, if you are proposing that you'd like to contribute the enhanced 
> PTI/Spectre (upstream) patches from the SLES 4.4 tree to 4.4 stable, and 
> have them merged instead of this patch series, then I would certainly 
> welcome it!

I'd in principle love us to push everything back to 4.4, but there are a 
few reasons (*) why that's not happening shortly.

Anyway, to point out explicitly what's really needed for those folks 
running 4.4-stable and relying on PTI providing The Real Thing(TM), it's 
either a 4.4-stable port of

	http://kernel.suse.com/cgit/kernel-source/plain/patches.suse/x86-entry-64-use-a-per-cpu-trampoline-stack.patch?id=3428a77b02b1ba03e45d8fc352ec350429f57fc7

or making THREADINFO_GFP imply __GFP_ZERO.

(*) IBRS is not upstream, we historically have had very different x86 
    codebase compared to either 4.4, 4.4-stable or current Linus' tree, 
    and there are simply too many things happening right now to give this 
    high enough priority, sadly. We're not fully-dependent downstream 
    consumer of -stable any more, so this is one of the expected outcomes, 
    unfortunately; we don't immediately benefit from pushing our 
    downstream changes to stable, as we have to carry those over forward
    ourselves anyway.

Thanks,

-- 
Jiri Kosina
SUSE Labs
