Date: Wed, 27 Sep 2000 09:32:39 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <20000927004716.A26621@l-t.ee>
Message-ID: <Pine.LNX.4.21.0009270931400.993-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marko Kreen <marko@l-t.ee>
Cc: Alexander Viro <viro@math.psu.edu>, Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Sep 2000, Marko Kreen wrote:

> > Why?
> > 
> > > +                               } else if (de->name[2])
> > 
> Sorry, I had a hard day and I should have gone to sleep already...

hey, you made Alexander notice an endianness bug so it was ok :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
