Message-ID: <393E8AEF.7A782FE4@reiser.to>
Date: Wed, 07 Jun 2000 10:48:31 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to> <20000607121243.F29432@redhat.com>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Use reservations.  That's the point --- you reserve in advance, so that
> the VM can *guarantee* that you can continue to pin more pages up to
> the maximum you have reserved.  You take a reservation before starting
> a fs operation, so that if you need to block, it doesn't prevent the
> running transaction from being committed.
> 
> Cheers,
>  Stephen

Ok, let's admit it, we have been agreeing on this with you for 9 months and no
code has been written by any of us.:-/

Hnas
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
