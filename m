Date: Tue, 5 Jun 2001 23:14:54 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Message-ID: <20010605231454.P26756@redhat.com>
References: <Pine.LNX.4.21.0106051646570.2997-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0106051646570.2997-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Tue, Jun 05, 2001 at 04:48:46PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, =?iso-8859-1?Q?Andr=E9_Dahlqvist?= <anedah-9@sm.luth.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 05, 2001 at 04:48:46PM -0300, Marcelo Tosatti wrote:
 
> I'm resending the reapswap patch for inclusion into -ac series. 

Isn't it broken in this state?  Checking page_count, page->buffers and
PageSwapCache without the appropriate locks is dangerous.  I think you
need the page lock at the very least before making this test.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
