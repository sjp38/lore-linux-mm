Date: Wed, 7 Jun 2000 16:51:01 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607165101.D4058@home.ds9a.nl>
References: <20000607144102.F30951@redhat.com> <Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva> <20000607154620.O30951@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000607154620.O30951@redhat.com>; from sct@redhat.com on Wed, Jun 07, 2000 at 03:46:20PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 07, 2000 at 03:46:20PM +0100, Stephen C. Tweedie wrote:

> It doesn't matter.  *If* the filesystem knows better than the 
> page cleaner what progress can be made, then let the filesystem
> make progress where it can.  There are likely to be transaction

I'm happy to see you talking to each other in a productive way. Once I said
it wasn't just about the code, all you guys have been talking about is
design :-)

But the main point of this message is that you can stop CC'ing me, as this
is all far over my head. 

Thanks.

Regards,

Bert Hubert.

-- 
                       |              http://www.rent-a-nerd.nl
                       |                     - U N I X -
                       |          Inspice et cautus eris - D11T'95
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
