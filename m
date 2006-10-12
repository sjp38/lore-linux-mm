Date: Thu, 12 Oct 2006 15:09:42 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 5/5] oom: invoke OOM killer from pagefault handler
Message-Id: <20061012150942.42e05898.akpm@osdl.org>
In-Reply-To: <20061012151907.GB18463@wotan.suse.de>
References: <20061012120102.29671.31163.sendpatchset@linux.site>
	<20061012120150.29671.48586.sendpatchset@linux.site>
	<452E5B4D.7000402@sw.ru>
	<20061012151907.GB18463@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Kirill Korotaev <dev@sw.ru>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2006 17:19:07 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Thu, Oct 12, 2006 at 07:12:13PM +0400, Kirill Korotaev wrote:
> > Nick,
> > 
> > AFAICS, 1 page allocation which is done in page fault handler
> > can fail in the only case - OOM kills current, so if we failed
> > we should have TIF_MEMDIE and just kill current.
> > Selecting another process for killing if page fault fails means
> > taking another victim with the one being already killed.
> > 
> 
> Hi Kirill,
> 
> I don't quite understand you.

Kirill is claiming that the only occasion on which a pagefault handler would
get an oom is when it killed itself in the oom handler.

> If the page allocation fails in the
> fault handler, we don't want to kill current if it is marked as
> OOM_DISABLE or sysctl_panic_on_oom is set... imagine a critical
> service in a failover system.
> 
> It should be quite likely for another process to be kiled and
> provide enough memory to keep the system running. Presuming you
> have faith in the concept of the OOM killer ;)

I'm a bit wobbly about this one.  Some before-and-after testing results
would help things along..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
