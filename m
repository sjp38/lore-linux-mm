Date: Thu, 20 Apr 2006 21:41:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] split zonelist and use nodemask for page allocation [1/4]
In-Reply-To: <20060421131147.81477c93.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604202140160.23511@schroedinger.engr.sgi.com>
References: <20060421131147.81477c93.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Apr 2006, KAMEZAWA Hiroyuki wrote:

> 
> These patches modifies zonelist and add nodes_list[]. They also modify 
> alloc_pages to use nodemask instead of zonelist.

That is great. I have thought that this would be necessary for a long 
time. The zonelist stuff is rather difficult to handle. This could allow a 
clean up of the memory policy layer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
