Date: Tue, 17 Aug 1999 14:38:20 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908170629.XAA23911@pizda.davem.net>
Message-ID: <Pine.LNX.4.10.9908171437440.414-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: kanoj@google.engr.sgi.com, alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, David S. Miller wrote:

>   From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
>   Date:   Mon, 16 Aug 1999 16:28:58 -0700 (PDT)
>
>   For example, on a 2.2.10 kernel:
>   [kanoj@entity kern]$ gid __va | grep drivers
>   drivers/char/mem.c:124: if (copy_to_user(buf, __va(p), count))
>   drivers/char/mem.c:142: return do_write_mem(file, __va(p), p, buf, count, ppos);
>
>Ok, this one could be a problem.

It isn't. The bigmem is not readable from /dev/mem right now.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
