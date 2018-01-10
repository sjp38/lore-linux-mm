Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 056E76B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 22:08:16 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id e19so1827716otf.4
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 19:08:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 93si1507059otp.167.2018.01.09.19.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 19:08:15 -0800 (PST)
Date: Wed, 10 Jan 2018 11:08:04 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180110030804.GB1744@dhcp-128-110.nay.redhat.com>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <20180109010927.GA2082@dhcp-128-65.nay.redhat.com>
 <20180109054131.GB1935@localhost.localdomain>
 <20180109072440.GA6521@dhcp-128-65.nay.redhat.com>
 <20180109090552.45ddfk2y25lf4uyn@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109090552.45ddfk2y25lf4uyn@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Baoquan He <bhe@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org

On Tue, Jan 09, 2018 at 12:05:52PM +0300, Kirill A. Shutemov wrote:
> On Tue, Jan 09, 2018 at 03:24:40PM +0800, Dave Young wrote:
> > On 01/09/18 at 01:41pm, Baoquan He wrote:
> > > On 01/09/18 at 09:09am, Dave Young wrote:
> > > 
> > > > As for the macro name, VMCOREINFO_SYMBOL_ARRAY sounds better.
> 
> Yep, that's better.
> 
> > > I still think using vmcoreinfo_append_str is better. Unless we replace
> > > all array variables with the newly added macro.
> > > 
> > > vmcoreinfo_append_str("SYMBOL(mem_section)=%lx\n",
> > >                                 (unsigned long)mem_section);
> > 
> > I have no strong opinion, either change all array uses or just introduce
> > the macro and start to use it from now on if we have similar array
> > symbols.
> 
> Do you need some action on my side or will you folks take care about this?

I think Baoquan was suggesting to update all array users in current code, if you can check every VMCOREINFO_SYMBOL and update all the arrays he will be happy. But if can not do it easily I'm fine with a VMCOREINFO_SYMBOL_ARRAY changes only now, we kdump people can do it later as well. 

> 
> -- 
>  Kirill A. Shutemov

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
