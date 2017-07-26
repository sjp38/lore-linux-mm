Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 294A26B02F3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:43:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x64so10293249wmg.11
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:43:39 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id o128si278047wmd.102.2017.07.26.09.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 09:43:37 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id c184so8067653wmd.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:43:37 -0700 (PDT)
Date: Wed, 26 Jul 2017 19:43:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 08/10] x86/mm: Replace compile-time checks for 5-level
 with runtime-time
Message-ID: <20170726164335.xaajz5ltzhncju26@node.shutemov.name>
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
 <20170718141517.52202-9-kirill.shutemov@linux.intel.com>
 <6841c4f3-6794-f0ac-9af9-0ceb56e49653@suse.com>
 <20170725090538.26sbgb4npkztsqj3@black.fi.intel.com>
 <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39cb1e36-f94e-32ea-c94a-2daddcbf3408@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 26, 2017 at 09:28:16AM +0200, Juergen Gross wrote:
> On 25/07/17 11:05, Kirill A. Shutemov wrote:
> > On Tue, Jul 18, 2017 at 04:24:06PM +0200, Juergen Gross wrote:
> >> Xen PV guests will never run with 5-level-paging enabled. So I guess you
> >> can drop the complete if (IS_ENABLED(CONFIG_X86_5LEVEL)) {} block.
> > 
> > There is more code to drop from mmu_pv.c.
> > 
> > But while there, I thought if with boot-time 5-level paging switching we
> > can allow kernel to compile with XEN_PV and XEN_PVH, so the kernel image
> > can be used in these XEN modes with 4-level paging.
> > 
> > Could you check if with the patch below we can boot in XEN_PV and XEN_PVH
> > modes?
> 
> We can't. I have used your branch:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
> la57/boot-switching/v2
> 
> with this patch applied on top.
> 
> Doesn't boot PV guest with X86_5LEVEL configured (very early crash).

Hm. Okay.

Have you tried PVH?

> Doesn't build with X86_5LEVEL not configured:
> 
>   AS      arch/x86/kernel/head_64.o

I've fixed the patch and split the patch into two parts: cleanup and
re-enabling XEN_PV and XEN_PVH for X86_5LEVEL.

There's chance that I screw somthing up in clenaup part. Could you check
that?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
