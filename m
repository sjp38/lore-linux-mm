Message-ID: <396445FF.D1C04180@augan.com>
Date: Thu, 06 Jul 2000 10:40:31 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: nice vmm test case
References: <39636E66.CE21C296@ucla.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> vmscan.c goes through all the pages (at least on my machine) pretty
> fast, and that not all pages are found on the first iteration. If that
> were NOT the case we would be in BIG trouble, because it would never
> scan small processes until all the big ones had been scanned.  Also,
> swap_cnt is not update when the RSS changes...

I'm not talking about the scanning speed. What I'm seeing is that vi
continuously touches it pages, but as soon as _some_ pages are needed,
_all_ pages are swapped out. An operation that took a few minutes
before, takes now several hours (hmm, maybe days... the test that I
started on 2.2 yesterday still isn't finished :( ).

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
