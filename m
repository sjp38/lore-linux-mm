From: Christoph Rohland <cr@sap.com>
Subject: Re: [Lse-tech] [rfc][api] Shared Memory Binding
Date: Thu, 13 Feb 2003 10:48:07 +0100
In-Reply-To: <3E4978B6.9030201@us.ibm.com> (Matthew Dobson's message of
 "Tue, 11 Feb 2003 14:27:02 -0800")
Message-ID: <ovk7g4ecko.fsf@sap.com>
References: <DD755978BA8283409FB0087C39132BD1A07CD2@fmsmsx404.fm.intel.com>
	<3E4978B6.9030201@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: "Luck, Tony" <tony.luck@intel.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matt,

On Tue, 11 Feb 2003, Matthew Dobson wrote:
> I'd hoped to see how this proposal and pending patch went over with
> everyone, before attempting anything more broad.  My last attempt at
> something similar to this failed due to being too invasive and
> complicated.  My thoughts were to try something fairly
> straightforward and simple this time. 

But SYSV shm is a thin layer on top of tmpfs, which again is a thin
layer on top of the page cache. 

So if you want to have something simple, you should work on the
generic layer. For me a general mmbind() makes much more sense.

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
