Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14DCB6B029B
	for <linux-mm@kvack.org>; Tue, 15 May 2018 09:51:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a5-v6so106859plp.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 06:51:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n10-v6si63101pgp.457.2018.05.15.06.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 06:51:00 -0700 (PDT)
Date: Tue, 15 May 2018 06:50:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515135056.GG31599@bombadil.infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
 <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
 <20180515120355.GE31599@bombadil.infradead.org>
 <afe2c02f-3ecd-5f54-53ab-d45c11a5b4aa@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afe2c02f-3ecd-5f54-53ab-d45c11a5b4aa@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, May 15, 2018 at 04:29:22PM +0300, Boaz Harrosh wrote:
> On 15/05/18 15:03, Matthew Wilcox wrote:
> > You're getting dangerously close to admitting that the entire point
> > of this exercise is so that you can link non-GPL NetApp code into the
> > kernel in clear violation of the GPL.
> 
> It is not that at all. What I'm trying to do is enable a zero-copy,
> synchronous, low latency, low overhead. highly parallel - a new modern
> interface with application servers.

... and fully buzzword compliant.

> You yourself had such a project that could easily be served out-of-the-box
> with zufs, of a device that wanted to sit in user-mode.

For a very different reason.  I think the source code to that project
is publically available; the problem is that it's not written in C.

> Sometimes it is very convenient and needed for Servers to sit in
> user-mode. And this interface allows that. And it is not always
> a licensing thing. Though yes licensing is also an issue sometimes.
> It is the reality we are living in.
> 
> But please indulge me I am curious how the point of signing /sbin/
> servers, made you think about GPL licensing issues?
> 
> That said, is your point that as long as user-mode servers are sloooowwww
> they are OK to be supported but if they are as fast as the kernel,
> (as demonstrated a zufs based FS was faster then xfs-dax on same pmem)
> Then it is a GPL violation?

No.  Read what Linus wrote:

   NOTE! This copyright does *not* cover user programs that use kernel
 services by normal system calls - this is merely considered normal use
 of the kernel, and does *not* fall under the heading of "derived work".

What you're doing is far beyond that exception.  You're developing in
concert a userspace and kernel component, and claiming that the GPL does
not apply to the userspace component.  I'm not a lawyer, but you're on
very thin ice.
