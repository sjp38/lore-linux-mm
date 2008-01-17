Date: Thu, 17 Jan 2008 13:51:37 +0100
From: Rogier Wolff <R.E.Wolff@BitWizard.nl>
Subject: Re: [PATCH -v5 2/2] Updating ctime and mtime at syncing
Message-ID: <20080117125137.GA12191@bitwizard.nl>
References: <12005314662518-git-send-email-salikhmetov@gmail.com> <1200531471556-git-send-email-salikhmetov@gmail.com> <E1JFSgG-0006G1-6V@pomaz-ex.szeredi.hu> <4df4ef0c0801170416s5581ae28h90d91578baa77738@mail.gmail.com> <E1JFU7r-0006PK-So@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1JFU7r-0006PK-So@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 01:45:43PM +0100, Miklos Szeredi wrote:
> > > 4. Recording the time was the file data changed
> > >
> > > Finally, I noticed yet another issue with the previous version of my patch.
> > > Specifically, the time stamps were set to the current time of the moment
> > > when syncing but not the write reference was being done. This led to the
> > > following adverse effect on my development system:
> > >
> > > 1) a text file A was updated by process B;
> > > 2) process B exits without calling any of the *sync() functions;
> > > 3) vi editor opens the file A;
> > > 4) file data synced, file times updated;
> > > 5) vi is confused by "thinking" that the file was changed after 3).
> 
> Updating the time in remove_vma() would fix this, no?

That sounds to me as the right thing to do. Although not explcitly
mentioned in the standard, it is the logical (latest allowable)
timestamp to put on the modifications by process B. 

	Roger. 

-- 
** R.E.Wolff@BitWizard.nl ** http://www.BitWizard.nl/ ** +31-15-2600998 **
**    Delftechpark 26 2628 XH  Delft, The Netherlands. KVK: 27239233    **
*-- BitWizard writes Linux device drivers for any device you may have! --*
Q: It doesn't work. A: Look buddy, doesn't work is an ambiguous statement. 
Does it sit on the couch all day? Is it unemployed? Please be specific! 
Define 'it' and what it isn't doing. --------- Adapted from lxrbot FAQ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
