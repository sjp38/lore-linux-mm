Date: Thu, 19 Feb 2004 19:32:10 +0100
From: Lars Marowsky-Bree <lmb@suse.de>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219183210.GX14000@marowsky-bree.de>
References: <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218162858.2a230401.akpm@osdl.org> <20040219123110.A22406@infradead.org> <20040219091129.GD1269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20040219091129.GD1269@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, torvalds@osd.org, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2004-02-19T01:11:29,
   "Paul E. McKenney" <paulmck@us.ibm.com> said:

> > And pokes deep into internal structures that it shouldn't.
> Again, the point of the patch is to get rid of such poking.

I think this fiddling about this particular exported symbol is hiding
the real issue.

It seems that Christoph believes that _inherently_, any filesystem
kernel module on Linux must be a derived work, because it is intimately
tied into the kernel core / VFS. I can certainly see the reasoning
here, and it is a valid point of view.

Do we want to allow non-OSS filesystems in kernel space at all? That's
the entire question.

Personally, I would go with "No" and support the consequences of this,
because I believe in Open Source; and that the value proposition of
Linux is /not/ in binary-only modules, and I would /not/ sacrifice the
OSS principles of the literal core of the Linux project for a short term
pay-off.

(But I'm personally trying to solve that by making them superfluous and
putting them out of business by getting an OSS CFS, which seems to be
more amiable ;-)


Only if we can settle this, we can answer this export question. If we
want to allow them, the export is a perfectly reasonable thing to ask
for. If not, we probably need to add a few more _GPL barriers.

A rule of thumb might be whether any code in the tree uses a given
export, and if not, prune it. Anything which even we don't use or export
across the user-land boundary certainly qualifies as a kernel interna.

Currently, no kernel module seems to use this export. So I'd think such
a point could certainly be made.


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
