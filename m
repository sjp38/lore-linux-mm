Message-ID: <39C28F88.4F0F8E8A@kalifornia.com>
Date: Fri, 15 Sep 2000 14:07:20 -0700
From: David Ford <david@kalifornia.com>
Reply-To: david+validemail@kalifornia.com
MIME-Version: 1.0
Subject: Re: [PATCH *] VM patch for 2.4.0-test8
References: <Pine.LNX.4.21.0009141351510.10822-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0009151915040.7748-100000@tux.rsn.hk-r.se> <20000915213726.A9965@pcep-jamie.cern.ch>
Content-Type: multipart/mixed;
 boundary="------------9FDB3C736EF3D36388BD415F"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, Rik van Riel <riel@conectiva.com.br>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------9FDB3C736EF3D36388BD415F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Jamie Lokier wrote:

> Martin Josefsson wrote:
> > I've been trying to get my machine to swap but that seems hard with this
> > new patch :) I have 0kB of swap used after 8h uptime, and I have been
> > compiling, moving files between partitions and running md5sum on files
> > (that was a big problem before, everything ended up on the active list and
> > the swapping started and brought my machine down to a crawl)
>
> No preemptive page-outs?
>
> 0kB swap means if you suddenly need a lot of memory, inactive
> application pages have to be written to disk first.  There are always
> inactive application pages.
>
> Maybe the stats are inaccurate.

Perhaps, but I run most of my machines without swap.  They are between 64 and
256M.  Servers are pretty constant in their mem usage, I use about 75%.   The
workstations sometimes run down to a few megs free (read 'using netscape') and
I then turn on a swapfile.  But all in all they generally do dandy without swap
for days on some, months on others.

-d

--
"The difference between 'involvement' and 'commitment' is like an
eggs-and-ham breakfast: the chicken was 'involved' - the pig was
'committed'."



--------------9FDB3C736EF3D36388BD415F
Content-Type: text/x-vcard; charset=us-ascii;
 name="david.vcf"
Content-Transfer-Encoding: 7bit
Content-Description: Card for David Ford
Content-Disposition: attachment;
 filename="david.vcf"

begin:vcard 
n:Ford;David
x-mozilla-html:TRUE
org:<img src="http://www.kalifornia.com/images/paradise.jpg">
adr:;;;;;;
version:2.1
email;internet:david@kalifornia.com
title:Blue Labs Developer
x-mozilla-cpt:;28256
fn:David Ford
end:vcard

--------------9FDB3C736EF3D36388BD415F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
