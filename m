Date: Wed, 17 May 2000 23:58:59 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
Message-ID: <20000517235858.A478@acs.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: quintela@fi.udc.es, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Rik van Riel:
> I am now testing the patch on my small test machine and must
> say that things look just *great*. I can start up a gimp while
> bonnie is running without having much impact on the speed of
> either.
> 
> Interactive performance is nice and stability seems to be
> great as well.

We using the same patch?  I applied wait_buffers_02.patch from
Juan's site to pre9-2.  Running "Bonnie -s 250" on a 128 MB
machine causes extremely poor interactive performance.  The
machine is totaly unresponsive for up to a minute at a time.

    Neil
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
