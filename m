Date: Wed, 17 Jan 2007 01:57:34 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC 0/8] Cpuset aware writeback
Message-Id: <20070117015734.b74f8a6b.akpm@osdl.org>
In-Reply-To: <20070117000158.a2e7016e.pj@sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<20070116135325.3441f62b.akpm@osdl.org>
	<Pine.LNX.4.64.0701161407530.3545@schroedinger.engr.sgi.com>
	<20070116154054.e655f75c.akpm@osdl.org>
	<Pine.LNX.4.64.0701161602480.4263@schroedinger.engr.sgi.com>
	<20070116170734.947264f2.akpm@osdl.org>
	<Pine.LNX.4.64.0701161709490.4455@schroedinger.engr.sgi.com>
	<20070116183406.ed777440.akpm@osdl.org>
	<Pine.LNX.4.64.0701161920480.4677@schroedinger.engr.sgi.com>
	<20070116200506.d19eacf5.akpm@osdl.org>
	<Pine.LNX.4.64.0701162219180.5215@schroedinger.engr.sgi.com>
	<20070116230034.b8cb4263.akpm@osdl.org>
	<20070117000158.a2e7016e.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

> On Wed, 17 Jan 2007 00:01:58 -0800 Paul Jackson <pj@sgi.com> wrote:
> Andrew wrote:
> > - consider going off-cpuset for critical allocations. 
> 
> We do ... in mm/page_alloc.c:
> 
>          * This is the last chance, in general, before the goto nopage.
>          * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
>          * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
>          */
>         page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
> 
> We also allow GFP_KERNEL requests to escape the current cpuset, to the nearest
> enclosing mem_exclusive cpuset, which is typically a big cpuset covering most
> of the system.

hrm.   So how come NFS is getting oom-killings?

The oom-killer normally spews lots of useful stuff, including backtrace.  For some
reason that's not coming out for Christoph.  Log facility level, perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
