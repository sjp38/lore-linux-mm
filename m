Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE8F16B02FE
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 05:45:47 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 17-v6so8585746wma.1
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 02:45:47 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id 4si952269wrs.129.2018.02.07.02.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 02:45:46 -0800 (PST)
Message-ID: <1518000336.29698.1.camel@gmx.de>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
From: Mike Galbraith <efault@gmx.de>
Date: Wed, 07 Feb 2018 11:45:36 +0100
In-Reply-To: <20180207104111.sljc62bgkggmtio4@node.shutemov.name>
References: <20171222084623.668990192@linuxfoundation.org>
	 <20171222084625.007160464@linuxfoundation.org>
	 <1515302062.6507.18.camel@gmx.de>
	 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
	 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
	 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
	 <1515469448.6766.12.camel@gmx.de>
	 <d71ba136-71ba-333a-f99b-b8283e2dc545@cn.fujitsu.com>
	 <20180207104111.sljc62bgkggmtio4@node.shutemov.name>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, 2018-02-07 at 13:41 +0300, Kirill A. Shutemov wrote:
> On Wed, Feb 07, 2018 at 05:25:05PM +0800, Dou Liyang wrote:
> > Hi All,
> > 
> > I met the makedumpfile failed in the upstream kernel which contained
> > this patch. Did I missed something else?
> 
> None I'm aware of.
> 
> Is there a reason to suspect that the issue is related to the bug this patch
> fixed?

Still works fine for me with .today.  Box is only 16GB desktop box though.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
