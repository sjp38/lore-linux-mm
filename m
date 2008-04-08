Date: Tue, 8 Apr 2008 13:23:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/10] emm: notifier logic
In-Reply-To: <20080407071330.GH9309@duo.random>
Message-ID: <Pine.LNX.4.64.0804081320160.30874@schroedinger.engr.sgi.com>
References: <20080404223048.374852899@sgi.com> <20080404223131.469710551@sgi.com>
 <20080405005759.GH14784@duo.random> <Pine.LNX.4.64.0804062246030.18148@schroedinger.engr.sgi.com>
 <20080407060602.GE9309@duo.random> <Pine.LNX.4.64.0804062314080.18728@schroedinger.engr.sgi.com>
 <20080407071330.GH9309@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It may also be useful to allow invalidate_start() to fail in some contexts 
(try_to_unmap f.e., maybe if a certain flag is passed). This may allow the 
device to get out of tight situations (pending I/O f.e. or time out if 
there is no response for network communications). But then that 
complicates the API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
