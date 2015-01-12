Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 633DD6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:48:36 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so18203526qcq.11
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 06:48:36 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id y4si22680497qcl.31.2015.01.12.06.48.33
        for <linux-mm@kvack.org>;
        Mon, 12 Jan 2015 06:48:33 -0800 (PST)
Date: Mon, 12 Jan 2015 09:47:57 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-ID: <20150112144757.GE5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <20141210140347.GA23252@infradead.org>
 <20141210141211.GD2220@wil.cx>
 <20150105184143.GA665@infradead.org>
 <20150106004714.6d63023c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150106004714.6d63023c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Milosz Tanski <milosz@adfin.com>

On Tue, Jan 06, 2015 at 12:47:14AM -0800, Andrew Morton wrote:
> On Mon, 5 Jan 2015 10:41:43 -0800 Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Wed, Dec 10, 2014 at 09:12:11AM -0500, Matthew Wilcox wrote:
> > > On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
> > > > What is the status of this patch set?
> > > 
> > > I have no outstanding bug reports against it.  Linus told me that he
> > > wants to see it come through Andrew's tree.  I have an email two weeks
> > > ago from Andrew saying that it's on his list.  I would love to see it
> > > merged since it's almost a year old at this point.
> > 
> > And since then another month and aother merge window has passed.  Is
> > there any way to speed up merging big patch sets like this one?
> 
> I took a look at dax last time and found it to be unreviewable due to
> lack of design description, objectives and code comments.  Hopefully
> that's been addressed - I should get back to it fairly soon as I chew
> through merge window and holiday backlog.

Now that Jens has merged patches 1 and 2 into his block tree, you don't
need to spend any time looking at those.  If I could trouble you to
merge patches 3 & 4 through mm, the rest of the patches are VFS/ext2,
and maye we could merge those through Al's tree instead of taking your
valuable time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
