Message-ID: <42124551.8060401@sgi.com>
Date: Tue, 15 Feb 2005 12:54:09 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --	sys_page_migrate
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>	 <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>	 <1108242262.6154.39.camel@localhost>	 <20050214135221.GA20511@lnx-holt.americas.sgi.com>	 <1108407043.6154.49.camel@localhost>	 <20050214220148.GA11832@lnx-holt.americas.sgi.com>	 <1108419774.6154.58.camel@localhost>	 <20050215105056.GC19658@lnx-holt.americas.sgi.com> <1108492753.6154.82.camel@localhost>
In-Reply-To: <1108492753.6154.82.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2005-02-15 at 04:50 -0600, Robin Holt wrote:
> 
>>What is the fundamental opposition to an array from from-to node mappings?
>>They are not that difficult to follow.  They make the expensive traversal
>>of ptes the single pass operation.  The time to scan the list of from nodes
>>to locate the node this page belongs to is relatively quick when compared
>>to the time to scan ptes and will result in probably no cache trashing
>>like the long traversal of all ptes in the system required for multiple
>>system calls.  I can not see the node array as anything but the right way
>>when compared to multiple system calls.  What am I missing?
> 
> 
> I don't really have any fundamental opposition.  I'm just trying to make
> sure that there's not a simpler (better) way of doing it.  You've
> obviously thought about it a lot more than I have, and I'm trying to
> understand your process.
> 
> As far as the execution speed with a simpler system call.  Yes, it will
> likely be slower.  However, I'm not sure that the increase in scan time
> is all that significant compared to the migration code (it's pretty
> slow).
> 
> -- Dave
> 
> 
I'm worried about doing all of those find_get_page() things over and over
when the mapped file we are migrating is large.  I suppose one can argue
that that is never going to be the case (e. g. no one in their right mind
would migrate a job with a 300 GB mapped file).  So we are back to the
overlapping set of nodes issue.  Let me look into this some more.

-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
