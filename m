Date: Thu, 8 Nov 2007 12:20:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Plans for Onezonelist patch series ???
In-Reply-To: <20071108200607.GD23882@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711081218250.10074@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <1194535612.6214.9.camel@localhost>
 <1194537674.5295.8.camel@localhost> <Pine.LNX.4.64.0711081033570.7871@schroedinger.engr.sgi.com>
 <20071108184009.GC23882@skynet.ie> <Pine.LNX.4.64.0711081043420.7871@schroedinger.engr.sgi.com>
 <20071108200607.GD23882@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Mel Gorman wrote:

> I've rebased the patches to mm-broken-out-2007-11-06-02-32. However, the
> vanilla -mm and the one with onezonelist applied are locking up in the
> same manner. I'm way too behind at the moment to guess if it is a new bug
> or reported already. At best, I can say the patches are not making things
> any worse :) I'll go through the archives in the morning and do a bit more
> testing to see what happens.

I usually base my patches on Linus' tree as long as there is no tree 
available from Andrew. But that means that may have to 
approximate what is in there by adding this and that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
