Date: Thu, 20 Jul 2000 08:48:27 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: [PATCH] test5-1 vmfix-3.0
In-Reply-To: <3976205E.4C604102@norran.net>
Message-ID: <Pine.Linu.4.10.10007200815320.334-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Zdenek Kabelac <kabi+www@fi.muni.cz>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jul 2000, Roger Larsson wrote:

> Hi,
> 
> Another attempt.

Not much difference for make -j test.

For reference, I reran ac22clas [record holder] on the same tree.

test4+test5-1vmscan_oneliner+vmfix-3.0
real    10m16.038s (~mobile, one run went 12.5)
user    6m26.130s  (solid)
sys     0m33.070s  (solid)

ac22-clas:
real    7m35.950s  (solid)
user    6m27.630s  (solid)
sys     0m29.570s  (solid)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
