Date: Wed, 30 Jan 2008 16:44:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB patches in mm
Message-Id: <20080130164436.675b1267.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0801301549360.1722@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801291947420.22779@schroedinger.engr.sgi.com>
	<20080130153222.e60442de.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0801301549360.1722@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, matthew@wil.cx
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008 15:50:08 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 30 Jan 2008, Andrew Morton wrote:
> 
> > I'm inclined to just drop every patch which you've mentioned, let you merge
> > slub-2.6.25 into Linus's tree and then add git-slub.patch to the -mm
> > lineup.  OK?
> 
> Ok.

The way I'll do this is to hang onto all the slub patches which I have. 
Once those patches reappear in -mm (via you->mainline or via git-slub->mm)
then I'll drop them.  This way I get to detect lost patches.

So please send me the git URL when it suits you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
