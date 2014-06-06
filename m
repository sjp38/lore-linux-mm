Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 08C816B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 21:56:21 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id ho1so117185wib.2
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 18:56:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d16si44804624wiv.38.2014.06.05.18.56.20
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 18:56:20 -0700 (PDT)
Date: Thu, 5 Jun 2014 21:56:10 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: ima_mmap_file returning 0 to userspace as mmap result.
Message-ID: <20140606015610.GA23041@redhat.com>
References: <20140604233122.GA19838@redhat.com>
 <538FF4C4.5090300@gmail.com>
 <20140605155658.GA22673@redhat.com>
 <20140605162045.GA25474@redhat.com>
 <1402019369.5458.55.camel@dhcp-9-2-203-236.watson.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402019369.5458.55.camel@dhcp-9-2-203-236.watson.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jun 05, 2014 at 09:49:29PM -0400, Mimi Zohar wrote:
 
 > >  >  > > There's no mention of this return value in the man page, so I dug
 > >  >  > > into the kernel code, and it appears that we do..
 > >  >  > > 
 > >  >  > > sys_mmap
 > >  >  > > vm_mmap_pgoff
 > >  >  > > security_mmap_file
 > >  >  > > ima_file_mmap <- returns 0 if not PROT_EXEC
 > >  >  > > 
 > >  >  > > and then the 0 gets propagated up as a retval all the way to userspace.
 > >  > 
 > >  > I just realised that this affects even kernels with CONFIG_IMA unset,
 > >  > because there we just do 'return 0' unconditionally.
 > >  > 
 > >  > Also, it appears that kernels with CONFIG_SECURITY unset will also
 > >  > return a zero for the same reason.
 > > 
 > > Hang on, I was misreading that whole security_mmap_file ret handling code.
 > > There's something else at work here.  I'll dig and get a reproducer.
 > 
 > According to security.h, it should return 0 if permission is granted.
 > If IMA is not enabled, it should also return 0.  What exactly is the
 > problem?

Still digging. I managed to get this to reproduce constantly last night,
but no luck today.  From re-reading the code though, I think IMA/lsm isn't
the problem.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
