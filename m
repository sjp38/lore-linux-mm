Date: Tue, 11 Feb 2003 13:51:23 -0800 (PST)
From: Paul Jackson <pj@sgi.com>
Subject: RE: [Lse-tech] [rfc][api] Shared Memory Binding
In-Reply-To: <DD755978BA8283409FB0087C39132BD1A07CD2@fmsmsx404.fm.intel.com>
Message-ID: <Pine.LNX.4.44.0302111350020.4504-100000@turbo-linux.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: colpatch@us.ibm.com, "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Feb 2003, Luck, Tony wrote:
> Why tie this to the sysV ipc shm mechanism?  Couldn't you make
> a more general "mmbind()" call that applies to a "start, len"
> range of virtual addresses?

I'll second that motion.  Presumably this could work
on any range of pages, using the kernel routines to
split vmareas as need be.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
