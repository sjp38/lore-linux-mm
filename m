Date: Fri, 2 Mar 2001 17:10:20 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] count for buffer IO in page_launder()
Message-ID: <20010302171020.W28854@redhat.com>
References: <Pine.LNX.4.21.0102270353020.6519-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0102270353020.6519-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Tue, Feb 27, 2001 at 04:09:09AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Feb 27, 2001 at 04:09:09AM -0300, Marcelo Tosatti wrote:
> 
> page_launder() is not counting direct ll_rw_block() IO correctly in the
> flushed pages counter. 

Having not seen any follow to this, it's worth asking: what is the
expected consequence of _not_ including this?  Have you done any
performance testing on it?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
