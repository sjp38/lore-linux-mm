Date: Sat, 31 Jul 2004 07:43:02 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <16651.33755.359441.675409@laputa.namesys.com>
Message-ID: <Pine.LNX.4.58.0407310742140.6063@dhcp030.home.surriel.com>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
 <16651.33755.359441.675409@laputa.namesys.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Clusterfs.COM>
Cc: linux-mm@kvack.org, sjiang@cs.wm.edu
List-ID: <linux-mm.kvack.org>

On Sat, 31 Jul 2004, Nikita Danilov wrote:

> Token functions are declared to be no-ops if !CONFIG_SWAP, but here
> token is used for file-system backed page-fault.

I figure that if somebody disables CONFIG_SWAP they don't
want the extra code of token based thrashing control ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
