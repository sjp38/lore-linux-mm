Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBD56B0304
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 07:08:33 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a188so595320qkg.4
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 04:08:33 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 12si68527qtn.63.2018.02.07.04.08.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 04:08:32 -0800 (PST)
Date: Wed, 7 Feb 2018 20:08:27 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180207120827.GB30270@localhost.localdomain>
References: <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <1515469448.6766.12.camel@gmx.de>
 <d71ba136-71ba-333a-f99b-b8283e2dc545@cn.fujitsu.com>
 <20180207104111.sljc62bgkggmtio4@node.shutemov.name>
 <1518000336.29698.1.camel@gmx.de>
 <cd7e23ce-60a3-08ad-eb5d-21bb91df5937@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd7e23ce-60a3-08ad-eb5d-21bb91df5937@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Mike Galbraith <efault@gmx.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Takao Indoh <indou.takao@jp.fujitsu.com>

On 02/07/18 at 08:00pm, Dou Liyang wrote:
> Hi Kirill,Mike
> 
> At 02/07/2018 06:45 PM, Mike Galbraith wrote:
> > On Wed, 2018-02-07 at 13:41 +0300, Kirill A. Shutemov wrote:
> > > On Wed, Feb 07, 2018 at 05:25:05PM +0800, Dou Liyang wrote:
> > > > Hi All,
> > > > 
> > > > I met the makedumpfile failed in the upstream kernel which contained
> > > > this patch. Did I missed something else?
> > > 
> > > None I'm aware of.
> > > 
> > > Is there a reason to suspect that the issue is related to the bug this patch
> > > fixed?
> > 
> 
> I did a contrastive test by my colleagues Indoh's suggestion.
> 
> Revert your two commits:
> 
> commit 83e3c48729d9ebb7af5a31a504f3fd6aff0348c4
> Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Date:   Fri Sep 29 17:08:16 2017 +0300
> 
> commit 629a359bdb0e0652a8227b4ff3125431995fec6e
> Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Date:   Tue Nov 7 11:33:37 2017 +0300
> 
> ...and keep others unchanged, the makedumpfile works well.
> 
> > Still works fine for me with .today.  Box is only 16GB desktop box though.
> > 
> Btw, In the upstream kernel which contained this patch, I did two tests:
> 
>  1) use the makedumpfile as core_collector in /etc/kdump.conf, then
> trigger the process of kdump by echo 1 >/proc/sysrq-trigger, the
> makedumpfile works well and I can get the vmcore file.
> 
>      ......It is OK
> 
>  2) use cp as core_collector, do the same operation to get the vmcore file.
> then use makedumpfile to do like above:
> 
>     [douly@localhost code]$ ./makedumpfile -d 31 --message-level 31 -x
> vmlinux_4.15+ vmcore_4.15+_from_cp_command vmcore_4.15+

Oh, then please ignore my previous comment. Adding '-D' can give more
debugging message.

> 
>     ......It causes makedumpfile failed.
> 
> 
> Thanks,
> 	dou.
> 
> > 	-Mike
> > 
> > 
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
