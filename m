Date: Wed, 11 Oct 2006 11:21:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
Message-ID: <20061011092158.GA28449@wotan.suse.de>
References: <20061010121314.19693.75503.sendpatchset@linux.site> <20061010121332.19693.37204.sendpatchset@linux.site> <20061010213843.4478ddfc.akpm@osdl.org> <452C838A.70806@yahoo.com.au> <20061010230042.3d4e4df1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061010230042.3d4e4df1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2006 at 11:00:42PM -0700, Andrew Morton wrote:
> On Wed, 11 Oct 2006 15:39:22 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > But I see that it does read twice. Do you want that behaviour retained? It
> > seems like at this level it would be logical to read it once and let lower
> > layers take care of any retries?
> 
> argh.  Linus has good-sounding reasons for retrying the pagefault-path's
> read a single time, but I forget what they are.  Something to do with
> networked filesystems?  (adds cc)

While you're there, can anyone tell me why we want an external
ptracer to be able to access pages that are outside i_size? I
haven't removed the logic of course, but I'm curious about the
history and usage of such a thing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
