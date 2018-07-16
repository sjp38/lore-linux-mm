Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3430F6B0273
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:03:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x26-v6so29268893qtb.2
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 01:03:25 -0700 (PDT)
Received: from outgoing-stata.csail.mit.edu (outgoing-stata.csail.mit.edu. [128.30.2.210])
        by mx.google.com with ESMTP id v17-v6si207506qtg.359.2018.07.16.01.03.24
        for <linux-mm@kvack.org>;
        Mon, 16 Jul 2018 01:03:24 -0700 (PDT)
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
 <20180715112605.GA31680@kroah.com>
From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Message-ID: <cb9d4e82-639a-792c-0535-975c4cb4be57@csail.mit.edu>
Date: Mon, 16 Jul 2018 01:02:42 -0700
MIME-Version: 1.0
In-Reply-To: <20180715112605.GA31680@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, Denys Vlasenko <dvlasenk@redhat.com>, Bo Gan <ganb@vmware.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Ricardo Neri <ricardo.neri-calderon@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, ak@linux.intel.com, linux-tip-commits@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Josh Poimboeuf <jpoimboe@redhat.com>, xen-devel@lists.xenproject.org, =?UTF-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Sherry Hurwitz <sherry.hurwitz@amd.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>, Oleg Nesterov <oleg@redhat.com>, torvalds@linux-foundation.org, dwmw@amazon.co.uk, karahmed@amazon.de, Borislav Petkov <bp@alien8.de>, dave.hansen@linux.intel.com, linux@dominikbrodowski.net, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Joerg Roedel <joro@8bytes.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Kyle Huey <me@kylehuey.com>, Will Drewry <wad@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Thomas Garnier <thgarnie@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joe Konno <joe.konno@linux.intel.com>, kvm <kvm@vger.kernel.org>, Piotr Luc <piotr.luc@intel.com>, boris.ostrovsky@oracle.com, Jan Beulich <jbeulich@suse.com>, arjan@linux.intel.com, Alexander Kuleshov <kuleshovmail@gmail.com>, Juergen Gross <jgross@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?Q?J=c3=b6rg_Otte?= <jrg.otte@gmail.com>, tim.c.chen@linux.intel.com, Alexander Sergeyev <sergeev917@gmail.com>, Josh Triplett <josh@joshtriplett.org>, gnomes@lxorguk.ukuu.org.uk, Tony Luck <tony.luck@intel.com>, Laura Abbott <labbott@fedoraproject.org>, dave.hansen@intel.com, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexey Makhalov <amakhalov@vmware.com>, Dave Hansen <dave@sr71.net>, ashok.raj@intel.com, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?TWlja2HDq2xTYWxhw7xu?= <mic@digikod.net>, Fenghua Yu <fenghua.yu@intel.com>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Vince Weaver <vincent.weaver@maine.edu>, Prarit Bhargava <prarit@redhat.com>, rostedt@goodmis.org, Dan Williams <dan.j.williams@intel.com>, Jim Mattson <jmattson@google.com>, Dave Young <dyoung@redhat.com>, linux-edac <linux-edac@vger.kernel.org>, Jon Masters <jcm@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Jiri Olsa <jolsa@redhat.com>, arjan.van.de.ven@intel.com, sironi@amazon.de, Frederic Weisbecker <fweisbec@gmail.com>, Kyle Huey <khuey@kylehuey.com>, Alexander Popov <alpopov@ptsecurity.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Nadav Amit <nadav.amit@gmail.com>, Yazen Ghannam <Yazen.Ghannam@amd.com>, Wanpeng Li <kernellwp@gmail.com>, Stephane Eranian <eranian@google.com>, David Woodhouse <dwmw2@infradead.org>, srivatsab@vmware.com

On 7/15/18 4:26 AM, Greg KH wrote:
> On Sat, Jul 14, 2018 at 02:25:43AM -0700, Srivatsa S. Bhat wrote:
>> Hi Greg,
>>
>> This patch series is a backport of the Spectre-v2 fixes (IBPB/IBRS)
>> and patches for the Speculative Store Bypass vulnerability to 4.4.y
>> (they apply cleanly on top of 4.4.140).
>>
>> I used 4.9.y as my reference when backporting to 4.4.y (as I thought
>> that would minimize the amount of fixing up necessary). Unfortunately
>> I had to skip the KVM fixes for these vulnerabilities, as the KVM
>> codebase is drastically different in 4.4 as compared to 4.9. (I tried
>> my best to backport them initially, but wasn't confident that they
>> were correct, so I decided to drop them from this series).
>>
>> You'll notice that the initial few patches in this series include
>> cleanups etc., that are non-critical to IBPB/IBRS/SSBD. Most of these
>> patches are aimed at getting the cpufeature.h vs cpufeatures.h split
>> into 4.4, since a lot of the subsequent patches update these headers.
>> On my first attempt to backport these patches to 4.4.y, I had actually
>> tried to do all the updates on the cpufeature.h file itself, but it
>> started getting very cumbersome, so I resorted to backporting the
>> cpufeature.h vs cpufeatures.h split and their dependencies as well. I
>> think apart from these initial patches, the rest of the patchset
>> doesn't have all that much noise. 
> 
> I've applied the "initial" patches to the 4.4-stable queue right now, as
> those were all just "housekeeping" stuff.  I'll let others review the
> rest of the series this week and see if anyone objects before throwing
> them at the test-bots.
> 

Sounds great! Thanks a lot!

> Many thanks for doing all of this work.
> 

Thank you Greg!
 
Regards,
Srivatsa
VMware Photon OS
