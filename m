Date: Fri, 9 Jun 2000 22:55:11 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: O_SYNC patches for 2.4.0-test1-ac11
Message-ID: <20000609225511.H2621@redhat.com>
References: <20000609223632.E2621@redhat.com> <m31z26v7zd.fsf@otr.mynet.cygnus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m31z26v7zd.fsf@otr.mynet.cygnus.com>; from drepper@redhat.com on Fri, Jun 09, 2000 at 02:51:18PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@cygnus.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Theodore Ts'o <tytso@valinux.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jun 09, 2000 at 02:51:18PM -0700, Ulrich Drepper wrote:
> 
> Have you thought about O_RSYNC and whether it is possible/useful to
> support it separately?

It would be possible and useful, but it's entirely separate from the
write path and probably doesn't make sense until we've got O_DIRECT
working (O_RSYNC is closely related to that).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
