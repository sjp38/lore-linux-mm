Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DCEA6B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 09:49:42 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so10643094plq.8
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 06:49:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n70-v6si1479004pfa.320.2018.08.07.06.49.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 06:49:40 -0700 (PDT)
Date: Tue, 7 Aug 2018 15:49:34 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
Message-ID: <20180807134934.GA16837@kroah.com>
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
 <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
 <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
 <nycvar.YFH.7.76.1807242351500.997@cbobk.fhfr.pm>
 <CAGXu5jJvTF0KXs+3J32u5v1Ba5gZd0Umgib6D6++ie+LzqnuWA@mail.gmail.com>
 <c616c38b-52cc-2f88-7ea3-00f3a572255a@csail.mit.edu>
 <CAGXu5j+Y5TNBY1WCz=4E8B5nFo2jzyswg6iaQja_92GZB+hE0w@mail.gmail.com>
 <8a87a705-97c0-eb3d-8878-8ffe052f065d@csail.mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8a87a705-97c0-eb3d-8878-8ffe052f065d@csail.mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Cc: Kees Cook <keescook@chromium.org>, Jiri Kosina <jikos@kernel.org>, "# 3.4.x" <stable@vger.kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel <xen-devel@lists.xenproject.org>, =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, LKML <linux-kernel@vger.kernel.org>, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jan Beulich <jbeulich@suse.com>, Arjan van de Ven <arjan@linux.intel.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?iso-8859-1?Q?J=F6rg?= Otte <jrg.otte@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?iso-8859-1?Q?Micka=EBlSala=FCn?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linux-MM <linux-mm@kvack.org>, Jiri Olsa <jolsa@redhat.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com, srinidhir@vmware.com, khlebnikov@yandex-team.ru, catalin.marinas@arm.com

On Fri, Aug 03, 2018 at 04:20:31PM -0700, Srivatsa S. Bhat wrote:
> On 8/2/18 3:22 PM, Kees Cook wrote:
> > On Thu, Aug 2, 2018 at 12:22 PM, Srivatsa S. Bhat
> > <srivatsa@csail.mit.edu> wrote:
> >> On 7/26/18 4:09 PM, Kees Cook wrote:
> >>> On Tue, Jul 24, 2018 at 3:02 PM, Jiri Kosina <jikos@kernel.org> wrote:
> >>>> On Tue, 24 Jul 2018, Srivatsa S. Bhat wrote:
> >>>>
> >>>>> However, if you are proposing that you'd like to contribute the enhanced
> >>>>> PTI/Spectre (upstream) patches from the SLES 4.4 tree to 4.4 stable, and
> >>>>> have them merged instead of this patch series, then I would certainly
> >>>>> welcome it!
> >>>>
> >>>> I'd in principle love us to push everything back to 4.4, but there are a
> >>>> few reasons (*) why that's not happening shortly.
> >>>>
> >>>> Anyway, to point out explicitly what's really needed for those folks
> >>>> running 4.4-stable and relying on PTI providing The Real Thing(TM), it's
> >>>> either a 4.4-stable port of
> >>>>
> >>>>         http://kernel.suse.com/cgit/kernel-source/plain/patches.suse/x86-entry-64-use-a-per-cpu-trampoline-stack.patch?id=3428a77b02b1ba03e45d8fc352ec350429f57fc7
> >>>>
> >>>> or making THREADINFO_GFP imply __GFP_ZERO.
> >>>
> >>> This is true in Linus's tree now. Should be trivial to backport:
> >>> https://git.kernel.org/linus/e01e80634ecdd
> >>>
> >>
> >> Hi Jiri, Kees,
> >>
> >> Thank you for suggesting the patch! I have attached the (locally
> >> tested) 4.4 and 4.9 backports of that patch with this mail. (The
> >> mainline commit applies cleanly on 4.14).
> >>
> >> Greg, could you please consider including them in stable 4.4, 4.9
> >> and 4.14?
> > 
> > I don't think your v4.9 is sufficient: it leaves the vmapped stack
> > uncleared. v4.9 needs ca182551857 ("kmemleak: clear stale pointers
> > from task stacks") included in the backport (really, just adding the
> > memset()).
> > 
> 
> Ah, I see, thank you! I have attached the updated patchset for 4.9
> with this mail.
> 
> > Otherwise, yup, looks good.
> > 
> Thank you for reviewing the patches!
>  
> Regards,
> Srivatsa
> VMware Photon OS

These work for 4.9, do you also have a set for 4.4?

thanks,

greg k-h
