Date: Thu, 26 Jul 2007 11:20:25 +0100
From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Message-ID: <20070726102025.GJ27237@ftp.linux.org.uk>
References: <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de> <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu> <20070726023401.f6a2fbdf.akpm@linux-foundation.org> <20070726094024.GA15583@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070726094024.GA15583@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 26, 2007 at 11:40:24AM +0200, Ingo Molnar wrote:
> below is an updatedb hack that sets vfs_cache_pressure down to 0 during 
> an updatedb run. Could someone who is affected by the 'morning after' 
> problem give it a try? If this works then we can think about any other 
> measures ...

BTW, I really wonder how much pain could be avoided if updatedb recorded
mtime of directories and checked it.  I.e. instead of just doing blind
find(1), walk the stored directory tree comparing timestamps with those
in filesystem.  If directory mtime has not changed, don't bother rereading
it and just go for (stored) subdirectories.  If it has changed - reread the
sucker.  If we have a match for stored subdirectory of changed directory,
check inumber; if it doesn't match, consider the entire subtree as new
one.  AFAICS, that could eliminate quite a bit of IO...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
