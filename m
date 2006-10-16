Date: Mon, 16 Oct 2006 06:25:36 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [TAKE] memory page_alloc zonelist caching speedup
Message-ID: <20061016112535.GA13218@lnx-holt.americas.sgi.com>
References: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com> <200610161134.07168.ak@suse.de> <20061016032632.486f4235.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061016032632.486f4235.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 16, 2006 at 03:26:32AM -0700, Paul Jackson wrote:
> Andi wrote:
> > Yes but you will add latencies for cache line bounces won't you?
> > The old zone lists were completely read only. That is what worries me 
> > most.

Paul,  I think Andi is concerned that we will have a heavily shared
cache line which now becomes frequently invalidated.  That invalidate
is quite expensive compared to just letting the lines quietly leave the
cpus cache and refetching them.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
