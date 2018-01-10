Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB7E96B025F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 06:16:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z12so11202270pgv.6
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 03:16:42 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p64si10348261pga.821.2018.01.10.03.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 03:16:41 -0800 (PST)
Date: Wed, 10 Jan 2018 14:16:04 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180110111603.56disgew7ipusgjy@black.fi.intel.com>
References: <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <20180109010927.GA2082@dhcp-128-65.nay.redhat.com>
 <20180109054131.GB1935@localhost.localdomain>
 <20180109072440.GA6521@dhcp-128-65.nay.redhat.com>
 <20180109090552.45ddfk2y25lf4uyn@node.shutemov.name>
 <20180110030804.GB1744@dhcp-128-110.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110030804.GB1744@dhcp-128-110.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Baoquan He <bhe@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org

On Wed, Jan 10, 2018 at 03:08:04AM +0000, Dave Young wrote:
> On Tue, Jan 09, 2018 at 12:05:52PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Jan 09, 2018 at 03:24:40PM +0800, Dave Young wrote:
> > > On 01/09/18 at 01:41pm, Baoquan He wrote:
> > > > On 01/09/18 at 09:09am, Dave Young wrote:
> > > > 
> > > > > As for the macro name, VMCOREINFO_SYMBOL_ARRAY sounds better.
> > 
> > Yep, that's better.
> > 
> > > > I still think using vmcoreinfo_append_str is better. Unless we replace
> > > > all array variables with the newly added macro.
> > > > 
> > > > vmcoreinfo_append_str("SYMBOL(mem_section)=%lx\n",
> > > >                                 (unsigned long)mem_section);
> > > 
> > > I have no strong opinion, either change all array uses or just introduce
> > > the macro and start to use it from now on if we have similar array
> > > symbols.
> > 
> > Do you need some action on my side or will you folks take care about this?
> 
> I think Baoquan was suggesting to update all array users in current
> code, if you can check every VMCOREINFO_SYMBOL and update all the arrays
> he will be happy. But if can not do it easily I'm fine with a
> VMCOREINFO_SYMBOL_ARRAY changes only now, we kdump people can do it
> later as well. 

It seems it's the only array we have there. swapper_pg_dir is a potential
candidate, but it's 'unsigned long' on arm.

Below it patch with corrected macro name.

Please, consider applying.
