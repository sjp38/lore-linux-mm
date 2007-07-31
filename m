Date: Mon, 30 Jul 2007 21:47:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-Id: <20070730214756.c4211678.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain>
	<20070730132314.f6c8b4e1.akpm@linux-foundation.org>
	<20070731000138.GA32468@localdomain>
	<20070730172007.ddf7bdee.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
	<20070731015647.GC32468@localdomain>
	<Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
	<20070730192721.eb220a9d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007 19:36:04 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 30 Jul 2007, Andrew Morton wrote:
> 
> > That makes sense, but any fix we do here won't fix things for regular
> > reclaim.
> 
> Standard reclaim has the same issues. It uselessly keeps 
> scanning the unreclaimable file backed pages.

Well it shouldn't.  That's what all_unreclaimable is for.  And it does
work.  Or used to, five years ago.  Stuff like this has a habit of breaking
because we don't have a test suite.

> Fixing this will also 
> enhance regular reclaim.
> 
> > - account file-backed pages, BDI_CAP_NO_ACCT_DIRTY pages and
> >   BDI_CAP_NO_WRITEBACK separately.  ie: zone accounting pretty
> >   much follows the BDI_CAP_ selectors.
> 
> Or BDI_CAP_UNRECLAIMABLE.... 

Yeah, that's nice and direct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
