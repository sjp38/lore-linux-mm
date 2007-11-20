Date: Tue, 20 Nov 2007 13:38:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
In-Reply-To: <20071120133325.21fc819e.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711201337470.27539@schroedinger.engr.sgi.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie>
 <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com>
 <20071120141953.GB32313@csn.ul.ie> <Pine.LNX.4.64.0711201217430.26419@schroedinger.engr.sgi.com>
 <20071120133325.21fc819e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, nacc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 20 Nov 2007, Andrew Morton wrote:

> uhm, maybe.  It's getting toward the time when we should try to get -mm
> vaguely compiling and booting on some machines, which means stopping
> merging new stuff.  I left that too late in the 2.6.23 cycle.

Huh? mm1 works fine here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
