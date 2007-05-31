Date: Thu, 31 May 2007 06:57:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/41] fs: introduce write_begin, write_end, and perform_write aops
Message-ID: <20070531045754.GE20107@wotan.suse.de>
References: <20070524052844.860329000@suse.de> <20070524053155.065366000@linux.local0.net> <20070530213035.d7b6e3e0.akpm@linux-foundation.org> <20070531044327.GD20107@wotan.suse.de> <20070530215231.468e7f26.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070530215231.468e7f26.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2007 at 09:52:31PM -0700, Andrew Morton wrote:
> On Thu, 31 May 2007 06:43:27 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > INFO: lockdep is turned off.
> > > Code: 49 c0 89 44 24 0c 89 7c 24 08 89 5c 24 04 c7 04 24 ac 2a 49 c0 e8 e9 ff f7 ff e8 b4 21 f6 ff 8b 4d f0 e9 a6 fe ff ff 0f 0b eb fe <0f> 0b eb fe 8d 74 26 00 0f 0b eb fe 0f 0b eb fe 90 8d b4 26 00 
> > > EIP: [<c01a2938>] __block_prepare_write+0x348/0x360 SS:ESP 0068:de89fd60
> > > 
> > > 
> > > That's
> > > 
> > > 	BUG_ON(to > PAGE_CACHE_SIZE);
> > 
> > 
> > Thanks. Hmm, sorry I didn't test splice much. Does this fix it?
> 
> Don't know - I shelved the patches.

Oh, that didn't last long :P


> Given the great pile of build errors, I think we need the next rev.

I was working on bringing some of the others uptodate (hopefully
before you did another release). There is not much point in doing
that if they don't get merged because the patches just break again.

Were there build errors in any core code or converted filesystems?
AFAIKS it was just in reiser4 and a couple of the "cont" filesystems
that didn't get converted yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
