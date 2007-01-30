Message-ID: <45BE97D3.7090105@redhat.com>
Date: Mon, 29 Jan 2007 19:56:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Determining number of page faults caused by paging out
References: <268387.39294.qm@web56003.mail.re3.yahoo.com>
In-Reply-To: <268387.39294.qm@web56003.mail.re3.yahoo.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Daniels <johnqdaniels@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Daniels wrote:
> Hi,
> 
> I sent this message to kernelnewbies, but no one
> responded so I thought I'd see if anyone here could
> help me. Is there a way to determine the number of
> page faults which occur because a certain page has
> been paged out to disk and then back into memory (i.e.
> page faults that would have been avoided if the VM
> subsystem didn't swap the page to disk)?

You'll need my /proc/refaults patches for that.

See my paper on measuring resource demand, and the
patches (which I am forward porting, though I keep
getting distracted by other stuff):

http://people.redhat.com/riel/riel-OLS2006.pdf

http://surriel.com/patches/clockpro/

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
