Date: Wed, 7 May 2008 20:49:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 12/18] FS: ExtX filesystem defrag
In-Reply-To: <20080407231341.ac45cd9d.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0805072048470.15553@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230228.523868817@sgi.com>
 <20080407231341.ac45cd9d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Andrew Morton wrote:

> On Fri, 04 Apr 2008 16:02:10 -0700 Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Support defragmentation for extX filesystem inodes
> > 
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> > ---
> >  fs/ext2/super.c |    9 +++++++++
> >  fs/ext3/super.c |    8 ++++++++
> >  fs/ext4/super.c |    8 ++++++++
> 
> One patch per fs would be preferable please.
> 
> Is there much point in doing this if the ext2 user is mainly (or fully)
> using `-o nobh'?  

The defrag is for inodes, not for buffer heads.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
