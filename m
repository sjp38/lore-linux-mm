Date: Tue, 13 May 2003 15:00:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] Interface to invalidate regions of mmaps
Message-ID: <20030513220041.GW8978@holomorphy.com>
References: <20030513133636.C2929@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030513133636.C2929@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com, mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 01:36:36PM -0700, Paul E. McKenney wrote:
> This patch adds an API to allow networked and distributed filesystems
> to invalidate portions of (or all of) a file.  This is needed to 
> provide POSIX or near-POSIX semantics in such filesystems, as
> discussed on LKML late last year:
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=103609089604576&w=2
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=103167761917669&w=2

It looks possible to consolidate this with the internals of vmtruncate()
by passing in the maximum value representable by loff_t as the length.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
