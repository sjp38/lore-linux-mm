Date: Sun, 5 Dec 2004 09:44:37 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: pages not marked as accessed on non-page boundaries
In-Reply-To: <20041205141342.GA29174@cistron.nl>
Message-ID: <Pine.LNX.4.61.0412050944040.5582@chimarrao.boston.redhat.com>
References: <20041205141342.GA29174@cistron.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 Dec 2004, Miquel van Smoorenburg wrote:

> When you have a database accessing small amounts of data
> in an index file randomly, then most of those pages will
> not be marked as read and will be thrown out too soon.

> Would it be a good thing to fix this ? Patch is below.

Your patch makes a lot of sense to me.  This should help
keep database indexes in memory...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
