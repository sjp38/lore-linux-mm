Date: Fri, 12 Jul 2002 13:27:29 -0500 (CDT)
From: Paul Larson <plars@austin.ibm.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <Pine.LNX.4.44L.0207112011150.14432-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.33.0207121323230.13816-100000@eclipse.ltc.austin.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I've tried booting this patch on 2.5.25+rmap on an 8-way, with highmem.  I
got a loot of oops on boot (couldn't see the top one because it scrolled
off the screen) and I havn't had time to set it up with serial console yet
but I will.  Before I do that though I wanted to know if there are any
known issues with my configuration.  I vaguely remember someone mentioning
problems with multiple swap partitions a while back and that's what I have

/etc/fstab:
/dev/sda5               swap                    swap    defaults        0 0
/dev/sda6               swap                    swap    defaults        0 0
/dev/sda7               swap                    swap    defaults        0 0
/dev/sda8               swap                    swap    defaults        0 0
/dev/sda9               swap                    swap    defaults        0 0
/dev/sda10              swap                    swap    defaults        0 0
/dev/sda11              swap                    swap    defaults        0 0
/dev/sda12              swap                    swap    defaults        0 0

for a total of about 15GB swap.

Any known problems with this?

Thanks,
Paul Larson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
