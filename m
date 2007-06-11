Date: Mon, 11 Jun 2007 12:25:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070611185844.GO7443@v2.random>
Message-ID: <Pine.LNX.4.64.0706111225190.19541@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
 <20070609140552.GA7130@v2.random> <20070609143852.GB7130@v2.random>
 <Pine.LNX.4.64.0706110905080.15326@schroedinger.engr.sgi.com>
 <20070611165032.GJ7443@v2.random> <Pine.LNX.4.64.0706110952001.16068@schroedinger.engr.sgi.com>
 <20070611175130.GL7443@v2.random> <Pine.LNX.4.64.0706111055140.17264@schroedinger.engr.sgi.com>
 <20070611182232.GN7443@v2.random> <Pine.LNX.4.64.0706111133020.18327@schroedinger.engr.sgi.com>
 <20070611185844.GO7443@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Andrea Arcangeli wrote:

> This is the case I'm dealing with more commonly, normally the more
> swap more more it takes, and that's expectable. It should have
> improved too with the patchset.

Do you have a SLES10 kernel with these fixes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
