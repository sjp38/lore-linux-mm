From: Rob Landley <rob@landley.net>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Wed, 2 Nov 2005 18:10:27 -0600
References: <E1EXK87-0008JB-00@w-gerrit.beaverton.ibm.com>
In-Reply-To: <E1EXK87-0008JB-00@w-gerrit.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511021810.28948.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wednesday 02 November 2005 09:02, Gerrit Huizenga wrote:
> > but that's obviously not 'generic unpluggable kernel RAM'. It's very
> > special RAM: RAM that is free or easily freeable. I never argued that
> > such RAM is not returnable to the hypervisor.
>
>  Okay - and 'generic unpluggable kernel RAM' has not been a goal for
>  the hypervisor based environments.  I believe it is closer to being
>  a goal for those machines which want to hot-remove DIMMs or physical
>  memory, e.g. those with IA64 machines wishing to remove entire nodes

Keep in mind that just about any virtualized environment might benefit from 
being able to tell the parent system "we're not using this ram".  I mentioned 
UML, and I can also imagine a Linux driver that signals qemu (or even vmware) 
to say "this chunk of physical memory isn't currently in use", and even if 
they don't actually _free_ it they can call madvise() on it.

Heck, if we have prezeroing of large blocks, telling your emulator to 
madvise(ADV_DONTNEED) the pages for you should just plug right in to that 
infrastructure...

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
