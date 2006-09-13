Date: Wed, 13 Sep 2006 14:43:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.18-rc6.mm2] revert migrate_move_mapping to use direct
 radix tree slot update
In-Reply-To: <1158183622.5328.61.camel@localhost>
Message-ID: <Pine.LNX.4.64.0609131443190.19426@schroedinger.engr.sgi.com>
References: <1158174574.5328.37.camel@localhost>
 <Pine.LNX.4.64.0609131344450.19101@schroedinger.engr.sgi.com>
 <1158183622.5328.61.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Lee Schermerhorn wrote:

> If you want to do it that way, I'll need to supply another patch to
> clean up the compiler warnings [I think they were just warnings]
> resulting from the change [at your suggestion ;-)] in the interface to
> the radix tree functions.  

That would be nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
