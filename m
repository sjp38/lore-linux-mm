Date: Mon, 26 Mar 2007 23:49:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
Message-Id: <20070326234957.6b287dda.akpm@linux-foundation.org>
In-Reply-To: <E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu>
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<E1HVwy4-0002UD-00@dorka.pomaz.szeredi.hu>
	<20070326153153.817b6a82.akpm@linux-foundation.org>
	<E1HW5am-0003Mc-00@dorka.pomaz.szeredi.hu>
	<20070326232214.ee92d8c4.akpm@linux-foundation.org>
	<E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Mar 2007 09:36:50 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > There is surely no need to duplicate all that.
> 
> Yeah, we could teach generic_writepages() to conditionally not submit
> for io just test/clear pte dirtyness.
> 
> Maybe that would be somewhat cleaner, dunno.
> 
> Then there are the ram backed filesystems, which don't have dirty
> accounting and radix trees, and for which this pte walking is still
> needed to provide semantics consistent with normal filesystems.

hm.

I don't know how important all this is, really - we've had this bug for
ever and presumably we've already trained everyone to work around it.

What usage scenarios are people actually hurting from?  Is there anything
interesting in the mysterious Novell Bugzilla #206431?

Perhaps we can get away with doing something half-assed which covers most
requirements...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
