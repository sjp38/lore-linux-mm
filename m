Date: Mon, 23 Oct 2000 21:44:24 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Another wish item for your TODO list...
Message-ID: <20001023214424.B3749@redhat.com>
References: <20001023203853.A3295@redhat.com> <Pine.LNX.4.21.0010231810220.13115-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010231810220.13115-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 23, 2000 at 06:13:48PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Oct 23, 2000 at 06:13:48PM -0200, Rik van Riel wrote:
> 
> - if the memory item (file, shm segment, ...) is in use, move
>   the page to the inactive list (equivalent to our inactive_dirty)
> - if the item isn't in use, move the page to the cache list
>   (equivalent to our inactive_clean list)
> 
> We could extend this by moving *every* page of an item which
> isn't in use to the inactive_clean list once we move ONE page
> of such an item to that list (or reclaim it?).

For unused inodes which are never sequentially accessed, this should
make a lot of sense.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
