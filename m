Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2CF446B01B2
	for <linux-mm@kvack.org>; Sun, 23 May 2010 10:03:57 -0400 (EDT)
Received: by pvf33 with SMTP id 33so448847pvf.14
        for <linux-mm@kvack.org>; Sun, 23 May 2010 07:03:55 -0700 (PDT)
Date: Sun, 23 May 2010 23:03:48 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 0/3] mm: Swap checksum
Message-ID: <20100523140348.GA10843@barrios-desktop>
References: <4BF81D87.6010506@cesarb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BF81D87.6010506@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 22, 2010 at 03:08:07PM -0300, Cesar Eduardo Barros wrote:
> Add support for checksumming the swap pages written to disk, using the
> same checksum as btrfs (crc32c). Since the contents of the swap do not
> matter after a shutdown, the checksum is kept in memory only.
> 
> Note that this code does not checksum the software suspend image.
We have been used swap pages without checksum.

First of all, Could you explain why you need checksum on swap pages?
Do you see any problem which swap pages are broken?

I could miss your claim at old disucussion thread in LKML.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
