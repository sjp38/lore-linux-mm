Message-ID: <T5852fcda58ac1785e72b4@pcow029o.blueyonder.co.uk>
Content-Type: text/plain;
  charset="iso-8859-1"
From: James A Sutherland <james@sutherland.net>
Subject: Re: [PATCH *] rmap based VM  #11a
Date: Tue, 8 Jan 2002 14:50:24 +0000
References: <Pine.LNX.4.33L.0201081045030.872-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.33L.0201081045030.872-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 08 January 2002 12:45 pm, Rik van Riel wrote:
> The first maintenance release of the 11th version of the reverse
> mapping based VM is now available. It fixes agpgart_be and the
> OOM killer. Tests on diskless machines are especially appreciated.
>
> This is an attempt at making a more robust and flexible VM
> subsystem, while cleaning up a lot of code at the same time.
> The patch is available from:
>
>            http://surriel.com/patches/2.4/2.4.17-rmap-11a
> and        http://linuxvm.bkbits.net/
>
>
> My big TODO items for a next release are:
>   - fix page_launder() so it doesn't submit the whole
>     inactive_dirty list for writeout in one go

Hmm - is this necessarily a bad thing? For local disks, if you tell the 
elevator to give these writes minimal priority (i.e. avoid/minimise impact on 
other disk usage), writing out nice big chunks sounds like a good thing...


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
