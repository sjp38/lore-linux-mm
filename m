Subject: Re: [RFC] recursive pagetables for x86 PAE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200306141327.48649.oliver@neukum.org>
References: <1055540875.3531.2581.camel@nighthawk>
	 <200306141327.48649.oliver@neukum.org>
Content-Type: text/plain
Message-Id: <1055612996.3531.3270.camel@nighthawk>
Mime-Version: 1.0
Date: 14 Jun 2003 10:49:57 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Neukum <oliver@neukum.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2003-06-14 at 04:27, Oliver Neukum wrote:
> Am Freitag, 13. Juni 2003 23:47 schrieb Dave Hansen:
> > The following patches implement something which we like to call UKVA.
> > It's a Kernel Virtual Area which is private to a process, just like
> > Userspace.  You can put any process-local data that you want in the
> > area.  But, for now, I just put PTE pages in there.
> 
> If you put only such pages there, do you really want that memory to
> be per task? IMHO it should be per memory context to aid threading
> performance.

I think you're confusing what I mean by tasks and processes.  A task is
something with a task_struct and a kernel stack.  A process is a single
task, or multiple tasks that share an mm.   If things share an mm, they
share pagetables implicitly.  Per-process _is_  per memory context.

> Secondly, doesn't this scream for using large pages?

Large pages aren't used for generic user memory at all.  That would take
some serious surgery.  (Don't get Bill started on it :)

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
