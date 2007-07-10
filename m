From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [RFC] fsblock
Date: Mon, 9 Jul 2007 20:37:09 -0500
References: <20070624014528.GA17609@wotan.suse.de> <20070710005419.GB8779@wotan.suse.de> <Pine.LNX.4.64.0707091756020.2348@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707091756020.2348@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200707092037.10267.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 09 July 2007, Christoph Lameter wrote:
> On Tue, 10 Jul 2007, Nick Piggin wrote:
> > There are no changes to the filesystem API for large pages (although I
> > am adding a couple of helpers to do page based bitmap ops). And I don't
> > want to rely on contiguous memory. Why do you think handling of large
> > pages (presumably you mean larger than page sized blocks) is strange?
>
> We already have a way to handle large pages: Compound pages.

Um, no, we don't, assuming by compound pages you mean order > 0 pages..  None 
of the stack of changes necessary to make these pages viable has yet been 
accepted, ie antifrag, defrag, and variable page cache.  While these changes 
may yet all go in and work wonderfully, I applaud Nick's alternative solution 
that does not include a depency on them.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
