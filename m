Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: what is using memory?
Date: Mon, 11 Jun 2001 07:37:46 -0400
References: <l03130300b74a2f8d4db6@[192.168.239.105]>
In-Reply-To: <l03130300b74a2f8d4db6@[192.168.239.105]>
MIME-Version: 1.0
Message-Id: <01061107374601.06951@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>, Ed Tomlinson <tomlins@CAM.ORG>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 11 June 2001 04:20, Jonathan Morton wrote:
> >My box has
> >
> >320280K
> >
> >from proc/meminfo
> >
> > 17140	buffer
> >123696	cache
> > 32303	free
> >
> >leaving unaccounted
> >
> >123627K
>
> This is your processes' memory, the inode and dentry caches, and possibly
> some extra kernel memory which may be allocated after boot time.  It is
> *very* much accounted for.

No its not.  For instance the slab caches encompass the inode and dentry
caches.  Point I was/am tring to make is not that this memory is lost or
not need, but that is it _not_ accounted.  ie. There is not way to tell
what is using it, hense we cannot see leaks or places that could be 
optimized.

I have attempted to count all memory I could.  The 123M is what is left in
the kernel overhead bucket...

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
