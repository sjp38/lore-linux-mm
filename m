Date: Sun, 16 Feb 2003 09:50:52 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lse-tech] [rfc][api] Shared Memory Binding
Message-ID: <20030216095052.A6767@infradead.org>
References: <DD755978BA8283409FB0087C39132BD1A07CD2@fmsmsx404.fm.intel.com> <Pine.LNX.4.44.0302111350020.4504-100000@turbo-linux.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0302111350020.4504-100000@turbo-linux.engr.sgi.com>; from pj@sgi.com on Tue, Feb 11, 2003 at 01:51:23PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, colpatch@us.ibm.com, "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 11, 2003 at 01:51:23PM -0800, Paul Jackson wrote:
> I'll second that motion.  Presumably this could work
> on any range of pages, using the kernel routines to
> split vmareas as need be.

yes - it would be the same type of attribute setting we currently do
in mprotect, madvise, etc..  Which reminds me that I need to fix up
my split_vma() changes to do proper merging, maybe reusing bits from
akpm's new vma merging code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
