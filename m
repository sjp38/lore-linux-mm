Date: Wed, 6 Jun 2001 16:18:48 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
In-Reply-To: <l03130308b7439bb9f187@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106061618330.3769-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 6 Jun 2001, Jonathan Morton wrote:

> *** UPDATE *** : I applied the patch, and it really does help.  Compile
> time for MySQL is down to ~6m30s from ~8m30s with 48Mb physical, and the
> behaviour after the monster file is finished is much improved.  For
> reference, the MySQL compile takes ~5min on this box with all 256Mb
> available.  It's a 1GHz Athlon.

Which patch ? :) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
