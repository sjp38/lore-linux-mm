Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6461E6B0081
	for <linux-mm@kvack.org>; Sun, 14 Dec 2014 18:02:13 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so13283065wgh.27
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 15:02:13 -0800 (PST)
Date: Mon, 15 Dec 2014 01:02:08 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [GIT PULL] aio: changes for 3.19
Message-ID: <20141214230208.GA9217@node.dhcp.inet.fi>
References: <20141214202224.GH2672@kvack.org>
 <CA+55aFxV2h1NrE87Zt7U8bsrXgeO=Tf-DyQO8wBYZ=M7WEjxKg@mail.gmail.com>
 <20141214215221.GI2672@kvack.org>
 <20141214141336.a0267e95.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141214141336.a0267e95.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-aio@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>, Dmitry Monakhov <dmonakhov@openvz.org>

On Sun, Dec 14, 2014 at 02:13:36PM -0800, Andrew Morton wrote:
> On Sun, 14 Dec 2014 16:52:21 -0500 Benjamin LaHaise <bcrl@kvack.org> wrote:
> 
> > On Sun, Dec 14, 2014 at 01:47:32PM -0800, Linus Torvalds wrote:
> > > On Sun, Dec 14, 2014 at 12:22 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> > > >
> > > > Pavel Emelyanov (1):
> > > >       aio: Make it possible to remap aio ring
> > > 
> > > So quite frankly, I think this should have had more acks from VM
> > > people. The patch looks ok to me, but it took me by surprise, and I
> > > don't see much any discussion about it on linux-mm either..
> > 
> > Sadly, nobody responded.  Maybe akpm can chime in on this change (included 
> > below for ease of review and akpm added to the To:)?
> > 
> > 		-ben
> > -- 
> > "Thought is the essence of where you are now."
> > 
> > commit e4a0d3e720e7e508749c1439b5ba3aff56c92976
> > Author: Pavel Emelyanov <xemul@parallels.com>
> > Date:   Thu Sep 18 19:56:17 2014 +0400
> > 
> >     aio: Make it possible to remap aio ring
> 
> The patch appears to be a bugfix which coincidentally helps CRIU?
> 
> If it weren't for the bugfix part, I'd be asking "why not pass the
> desired virtual address into io_setup()?".

But it seems the problem is bigger than what the patch fixes. To me we are
too permisive on what vma can be remapped.

How can we know that it's okay to move vma around for random driver which
provide .mmap? Or I miss something obvious?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
