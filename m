Date: Wed, 27 Sep 2000 00:47:16 +0200
From: Marko Kreen <marko@l-t.ee>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
Message-ID: <20000927004716.A26621@l-t.ee>
References: <20000927001620.A26488@l-t.ee> <Pine.GSO.4.21.0009261825020.22614-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.21.0009261825020.22614-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Tue, Sep 26, 2000 at 06:31:04PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 06:31:04PM -0400, Alexander Viro wrote:
> On Wed, 27 Sep 2000, Marko Kreen wrote:
> > There is something fishy in ext2_empty_dir:
> 
> Why?
> 
> > +                               } else if (de->name[2])
> 
Sorry, I had a hard day and I should have gone to sleep already...
I did not think (anyway I tried ;) too hard on that [2], it seemed to me
with the following stuff as some copy-paste bug...

-- 
marko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
