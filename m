Subject: Re: Question on set_page_dirty()
From: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <20021212102930.C15158@nightmaster.csn.tu-chemnitz.de>
References: <3DF5BB06.A6F6AFFD@scs.ch> <20021211080102.GG20525@vagabond>
	<20021212102930.C15158@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 12 Dec 2002 12:42:43 +0000
Message-Id: <1039696963.2420.1.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Jan Hudec <bulb@ucw.cz>, Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 2002-12-12 at 09:29, Ingo Oeser wrote:
> set_page_dirty() can be used in all cases, IMHO, since it:
>    - will not sleep
...

Unfortunately, it can take both the inode_lock and pagecache_lock
spinlocks, so if you use it in the wrong place, with other locks already
held, you can cause a deadlock.  So you _do_ need to be a bit careful,
and you can't just use it with abandon.

Cheers,
 Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
