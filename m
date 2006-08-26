Message-ID: <3317.81.207.0.53.1156561530.squirrel@81.207.0.53>
In-Reply-To: <1156538183.26945.15.camel@lappy>
References: <20060825153946.24271.42758.sendpatchset@twins>
    <20060825154027.24271.43168.sendpatchset@twins>
    <1156536880.5927.29.camel@localhost>
    <1156538183.26945.15.camel@lappy>
Date: Sat, 26 Aug 2006 05:05:30 +0200 (CEST)
Subject: Re: [PATCH 4/4] nfs: deadlock prevention for NFS
From: "Indan Zupancic" <indan@nul.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

> 	/* Check if this were the first socks: */
> 	if (nr_socks - socks == 0)
> 		reserve += RX_RESERVE_PAGES;

Can of course be:

 	if (nr_socks == socks)
 		reserve += RX_RESERVE_PAGES;

Grumble,

Indan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
