Date: Thu, 19 Feb 2004 11:29:00 +0100
From: Lars Marowsky-Bree <lmb@suse.de>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219102900.GC14000@marowsky-bree.de>
References: <20040216190927.GA2969@us.ibm.com> <20040217073522.A25921@infradead.org> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20040218145132.460214b5.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>
Cc: paulmck@us.ibm.com, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2004-02-18T14:51:32,
   Andrew Morton <akpm@osdl.org> said:

> a) Does the export make technical sense?  Do filesystems have
>    legitimate need for access to this symbol?
> 
> (really, a) is sufficient grounds, but for real-world reasons:)

Technically, I assume both OCFS, Lustre, (OpenGFS), PolyServe and
basically /everyone/ doing a cluster file system, proprietary or not,
will eventually need this capability. Vendors have included hooks for
this in 2.4 already anyway.

So on technical grounds, I'm strongly inclined to support it, but I
would like to suggest that it is ensured that the hook is sufficient for
all of the named CFS.

Paul, have you spoken with them?

> b) Does the IBM filsystem meet the kernel's licensing requirements?

If you are worried about this one, you can export it GPL-only, which as
an Open Source developer I'd appreciate, but from a real-world business
perspective would be unhappy about ;-)


Sincerely,
    Lars Marowsky-Bree <lmb@suse.de>

-- 
High Availability & Clustering	      \ ever tried. ever failed. no matter.
SUSE Labs			      | try again. fail again. fail better.
Research & Development, SUSE LINUX AG \ 	-- Samuel Beckett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
