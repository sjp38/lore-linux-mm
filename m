Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 597CF6B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 04:05:57 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o2so5032142wmf.2
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 01:05:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d43sor6958696eda.22.2018.01.09.01.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 01:05:55 -0800 (PST)
Date: Tue, 9 Jan 2018 12:05:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180109090552.45ddfk2y25lf4uyn@node.shutemov.name>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <20180109010927.GA2082@dhcp-128-65.nay.redhat.com>
 <20180109054131.GB1935@localhost.localdomain>
 <20180109072440.GA6521@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109072440.GA6521@dhcp-128-65.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org

On Tue, Jan 09, 2018 at 03:24:40PM +0800, Dave Young wrote:
> On 01/09/18 at 01:41pm, Baoquan He wrote:
> > On 01/09/18 at 09:09am, Dave Young wrote:
> > 
> > > As for the macro name, VMCOREINFO_SYMBOL_ARRAY sounds better.

Yep, that's better.

> > I still think using vmcoreinfo_append_str is better. Unless we replace
> > all array variables with the newly added macro.
> > 
> > vmcoreinfo_append_str("SYMBOL(mem_section)=%lx\n",
> >                                 (unsigned long)mem_section);
> 
> I have no strong opinion, either change all array uses or just introduce
> the macro and start to use it from now on if we have similar array
> symbols.

Do you need some action on my side or will you folks take care about this?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
