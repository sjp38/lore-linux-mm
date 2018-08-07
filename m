Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58D1E6B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 15:19:52 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z6-v6so14405109qto.4
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 12:19:52 -0700 (PDT)
Received: from outgoing-stata.csail.mit.edu (outgoing-stata.csail.mit.edu. [128.30.2.210])
        by mx.google.com with ESMTP id c7-v6si711327qkc.96.2018.08.07.12.19.51
        for <linux-mm@kvack.org>;
        Tue, 07 Aug 2018 12:19:51 -0700 (PDT)
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
 <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
 <e57d5ac9-68d7-8ccf-6117-5a2f9d9e1112@csail.mit.edu>
 <nycvar.YFH.7.76.1807242351500.997@cbobk.fhfr.pm>
 <CAGXu5jJvTF0KXs+3J32u5v1Ba5gZd0Umgib6D6++ie+LzqnuWA@mail.gmail.com>
 <c616c38b-52cc-2f88-7ea3-00f3a572255a@csail.mit.edu>
 <CAGXu5j+Y5TNBY1WCz=4E8B5nFo2jzyswg6iaQja_92GZB+hE0w@mail.gmail.com>
 <8a87a705-97c0-eb3d-8878-8ffe052f065d@csail.mit.edu>
 <20180807134934.GA16837@kroah.com>
 <824c77d3-93d8-fb90-6eb0-afa4aeef6644@csail.mit.edu>
 <20180807191531.GA28682@kroah.com>
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Message-ID: <60dbd3d6-4b75-b375-8661-d921d77e0bbd@csail.mit.edu>
Date: Tue, 7 Aug 2018 12:19:12 -0700
MIME-Version: 1.0
In-Reply-To: <20180807191531.GA28682@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Kees Cook <keescook@chromium.org>, Jiri Kosina <jikos@kernel.org>, "# 3.4.x" <stable@vger.kernel.org>, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel <xen-devel@lists.xenproject.org>, =?UTF-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, LKML <linux-kernel@vger.kernel.org>, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jan Beulich <jbeulich@suse.com>, Arjan van de Ven <arjan@linux.intel.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?Q?J=c3=b6rg_Otte?= <jrg.otte@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?TWlja2HDq2xTYWxhw7xu?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linux-MM <linux-mm@kvack.org>, Jiri Olsa <jolsa@redhat.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com, srinidhir@vmware.com, khlebnikov@yandex-team.ru, catalin.marinas@arm.com

On 8/7/18 12:15 PM, Greg KH wrote:
> On Tue, Aug 07, 2018 at 12:08:07PM -0700, Srivatsa S. Bhat wrote:
>> Also, upstream commit e01e80634ecdde1 (fork: unconditionally clear
>> stack on fork) applies cleanly on 4.14 stable, so it would be great to
>> cherry-pick it to 4.14 stable as well.
> 
> It is already in the 4.14.60 release, did I somehow mess up the
> backport?
> 

Sorry, my bad! The backport in 4.14.60 looks fine. Thank you!
 
Regards,
Srivatsa
VMware Photon OS
