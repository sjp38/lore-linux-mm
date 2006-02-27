Date: Mon, 27 Feb 2006 18:27:18 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.64.0602270934260.3185@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602271823260.9352@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271658240.8669@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270934260.3185@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Christoph Lameter wrote:
> On Mon, 27 Feb 2006, Hugh Dickins wrote:
> 
> > > Or better do the rcu locking before calling page_lock_anon_vma 
> > > and the unlocking after spin_unlock to have proper nesting of locks?
> > 
> > No, page_lock_anon_vma is all about insulating the rest of the code
> > from these difficulties: I do prefer it as is.
> 
> Hmm... How about page_lock_anon_vma and page_unlock_anon_vma? This 
> 
> I fear that code reviewers will not realize that the freeing of the 
> anon_vma is in fact delayed much longer than a superficial review of the 
> page_lock_anon_vma reveals.
> 
> How about this patch:

I'd prefer not myself, perhaps someone else likes it.
And you haven't even based it on the check_mapped version you sent me,
which I then returned to you with more helpful comments.
Let's just move on?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
