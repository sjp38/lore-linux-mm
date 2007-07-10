Date: Mon, 9 Jul 2007 17:59:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] fsblock
In-Reply-To: <20070710005419.GB8779@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0707091756020.2348@schroedinger.engr.sgi.com>
References: <20070624014528.GA17609@wotan.suse.de>
 <Pine.LNX.4.64.0707091002170.15696@schroedinger.engr.sgi.com>
 <20070710005419.GB8779@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Nick Piggin wrote:

> > Hmmm.... I did not notice that yet but then I have not done much work 
> > there.
> 
> Notice what?

The bad code for the buffer heads.

> > > - A real "nobh" mode. nobh was created I think mainly to avoid problems
> > >   with buffer_head memory consumption, especially on lowmem machines. It
> > >   is basically a hack (sorry), which requires special code in filesystems,
> > >   and duplication of quite a bit of tricky buffer layer code (and bugs).
> > >   It also doesn't work so well for buffers with non-trivial private data
> > >   (like most journalling ones). fsblock implements this with basically a
> > >   few lines of code, and it shold work in situations like ext3.
> > 
> > Hmmm.... That means simply page struct are not working...
> 
> I don't understand you. jbd needs to attach private data to each bh, and
> that can stay around for longer than the life of the page in the pagecache.

Right. So just using page struct alone wont work for the filesystems.

> There are no changes to the filesystem API for large pages (although I
> am adding a couple of helpers to do page based bitmap ops). And I don't
> want to rely on contiguous memory. Why do you think handling of large
> pages (presumably you mean larger than page sized blocks) is strange?

We already have a way to handle large pages: Compound pages.

> Conglomerating the constituent pages via the pagecache radix-tree seems
> logical to me.

Meaning overhead to handle each page still exists? This scheme cannot 
handle large contiguous blocks as a single entity?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
