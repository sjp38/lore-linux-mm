Date: Fri, 15 Jul 2005 13:46:16 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [NUMA] Display and modify the memory policy of a process
 through /proc/<pid>/numa_policy
Message-ID: <20050715134616.43130b30@basil.nowhere.org>
In-Reply-To: <20050714230501.4a9df11e.pj@sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
	<Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
	<20050714230501.4a9df11e.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jul 2005 23:05:01 -0700
Paul Jackson <pj@sgi.com> wrote:

> Christoph wrote:
> > This is an implementation that deals with monitoring and managing running 
> > processes.
> 
> So is this patch roughly equivalent to adding a pid to the
> mbind/set_mempolicy/get_mempolicy system calls?
> 
> Not that I am advocating for or against adding doing that.  But this
> seems like alot of code, with new and exciting API details, just to
> add a pid argument, if such it be.
> 
> Andi - could you remind us all why you chose not to have a pid argument
> in these calls?

Because of locking issues and I don't think external processes
should mess with virtual addresses of other processes. There is
just no way to do the later cleanly and race free.

I haven't seen the patch, but from the description it sounds wrong.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
