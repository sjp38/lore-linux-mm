Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD81280303
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:05:42 -0400 (EDT)
Received: by qgy5 with SMTP id 5so38007999qgy.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 13:05:42 -0700 (PDT)
Date: Thu, 16 Jul 2015 22:03:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [mmotm:master 140/321] fs/built-in.o:undefined reference to
	`filemap_page_mkwrite'
Message-ID: <20150716200355.GA26594@redhat.com>
References: <201507160919.VRGXvreQ%fengguang.wu@intel.com> <20150716190503.GA22146@redhat.com> <20150716191258.GA22760@kvack.org> <20150716193856.GA25255@redhat.com> <20150716194553.GB22760@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716194553.GB22760@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Jeff Moyer <jmoyer@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 07/16, Benjamin LaHaise wrote:
>
> On Thu, Jul 16, 2015 at 09:38:56PM +0200, Oleg Nesterov wrote:
> > On 07/16, Benjamin LaHaise wrote:
> > >
> > > On Thu, Jul 16, 2015 at 09:05:03PM +0200, Oleg Nesterov wrote:
> > > > Thanks!
> > > ...
> > > > but the problem looks clear: CONFIG_MMU is not set, so we need
> > > > a dummy filemap_page_mkwrite() along with generic_file_mmap() and
> > > > generic_file_readonly_mmap().
> > > >
> > > > I'll send the fix, but...
> > > >
> > > > Benjamin, Jeff, shouldn't AIO depend on MMU? Or it can actually work even
> > > > if CONFIG_MMU=n?
> > >
> > > It should work when CONFIG_MMU=n,
> >
> > Really? I am just curious.
>
> I am not saying the code currently does, but that the use of the functionality
> is valid.  The code clearly doesn't at the moment, and given that nobody
> has complained, it's seems unlikely that there are any active users.

Hmm. Confused...

So sys_io_setup() can't succed if CONFIG_MMU=n.

Then why do we allow CONFIG_AIO=y in this case? And it is even
"default y" and needs EXPERT to disable...

But OK, I won't argue. I'll send the fix which fixes the build.

Thanks!

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
