Date: Wed, 28 Jun 2000 19:07:03 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000628190703.F2392@redhat.com>
References: <200006281554.KAA19007@jen.americas.sgi.com> <13214.962208390@cygnus.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13214.962208390@cygnus.co.uk>; from dwmw2@infradead.org on Wed, Jun 28, 2000 at 05:06:30PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: lord@sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 05:06:30PM +0100, David Woodhouse wrote:
> 
> MM is not exactly my field - I just know I want to be able to lock down a 
> user's buffer and treat it as if it were in kernel-space, passing its 
> address to functions which expect kernel buffers.

The pinning of user buffers is part of the reason we have kiobufs.
But why do you need to pass it to functions expecting kernel buffers?  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
