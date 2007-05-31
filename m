Date: Thu, 31 May 2007 07:15:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/41] fs: introduce write_begin, write_end, and perform_write aops
Message-ID: <20070531051539.GK20107@wotan.suse.de>
References: <20070524052844.860329000@suse.de> <20070524053155.065366000@linux.local0.net> <20070530213035.d7b6e3e0.akpm@linux-foundation.org> <20070531044327.GD20107@wotan.suse.de> <20070530215231.468e7f26.akpm@linux-foundation.org> <20070531045754.GE20107@wotan.suse.de> <20070530221121.7eadc807.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070530221121.7eadc807.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2007 at 10:11:21PM -0700, Andrew Morton wrote:
> On Thu, 31 May 2007 06:57:54 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > Don't know - I shelved the patches.
> > 
> > Oh, that didn't last long :P
> 
> I have a heap of other stuff to get out the door.  If I have to
> do just two bisects then it's 4AM and I give up then I have to repull
> everything and we're back to square one.
> 
> Fortunately, I didn't need to do a bisect this time.  That's unusual.
> 
> > 
> > > Given the great pile of build errors, I think we need the next rev.
> > 
> > I was working on bringing some of the others uptodate (hopefully
> > before you did another release). There is not much point in doing
> > that if they don't get merged because the patches just break again.
> 
> There's not much point in sending build-busting patches either.  Lots
> of people run allmodconfig.
> 
> My sympathy for broken patches is limited - you should see what happens
> over here ;)
> 
> I can do you a rollup with those patches reinstated after I've done rc3-mm1
> if you like.

OK, if you are planning to get a release out now, that's fair
enough.

If you can send that rollup, it would be good. I could try getting
everything to compile and do some more testing on it too.
 
 
> > Were there build errors in any core code or converted filesystems?
> > AFAIKS it was just in reiser4 and a couple of the "cont" filesystems
> > that didn't get converted yet.
> 
> The _cont filesystems, reiser4 and that revoke warning.

OK, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
