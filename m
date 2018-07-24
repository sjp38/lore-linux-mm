Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 98E2E6B0008
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:14:07 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o6-v6so4160550qtp.15
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:14:07 -0700 (PDT)
Received: from outgoing-stata.csail.mit.edu (outgoing-stata.csail.mit.edu. [128.30.2.210])
        by mx.google.com with ESMTP id s127-v6si2108312qkh.181.2018.07.24.13.14.06
        for <linux-mm@kvack.org>;
        Tue, 24 Jul 2018 13:14:06 -0700 (PDT)
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
 <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Message-ID: <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
Date: Tue, 24 Jul 2018 13:13:18 -0700
MIME-Version: 1.0
In-Reply-To: <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel@lists.xenproject.org, =?UTF-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, linux@dominikbrodowski.net, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jan Beulich <jbeulich@suse.com>, Arjan van de Ven <arjan@linux.intel.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?Q?J=c3=b6rg_Otte?= <jrg.otte@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, gnomes@lxorguk.ukuu.org.uk, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?TWlja2HDq2xTYWxhw7xu?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, gregkh@linux-foundation.org, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Jiri Olsa <jolsa@redhat.com>, arjan.van.de.ven@intel.com, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com

On 7/23/18 3:06 PM, Jiri Kosina wrote:
> On Sat, 14 Jul 2018, Srivatsa S. Bhat wrote:
> 
>> This patch series is a backport of the Spectre-v2 fixes (IBPB/IBRS)
>> and patches for the Speculative Store Bypass vulnerability to 4.4.y
>> (they apply cleanly on top of 4.4.140).
> 
> FWIW -- not sure how much inspiration you took from our SLE 4.4-based 
> tree, but most of the stuff is already there for quite some time 
> (including the non-upstream IBRS on kernel boundary on SKL+, trampoline 
> stack for PTI (which the original port didn't have), etc).
> 
> The IBRS SKL+ stuff has not been picked up by Greg, as it's non-upstream, 
> and the trampoline stack I believe was pointed out to stable@, but noone 
> really sat down and did the port (our codebase is different than 4.4.x 
> stable base), but it definitely should be done if someone has to put 100% 
> trust into the PTI port (either that, or at least zeroing out the kernel 
> thread thread stack ... we used to have temporarily that before we 
> switched over to proper entry trampoline in this version as well).
> 

I did glance at the SLES 4.4 kernel sometime ago, but there seemed to
be way too many custom patches and I wasn't sure in what ways your
PTI/Spectre fixes depended on the other (x86) patches in your tree. So
I decided to backport entirely from the 4.9 stable tree instead. My
reasoning was that, since the 4.9 stable patches were trusted to work
well, their 4.4 backports should work well too, as long as they are
backported correctly.
 
However, if you are proposing that you'd like to contribute the
enhanced PTI/Spectre (upstream) patches from the SLES 4.4 tree to 4.4
stable, and have them merged instead of this patch series, then I
would certainly welcome it!

Regards,
Srivatsa
VMware Photon OS
