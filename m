Date: Sun, 28 Jan 2007 21:34:23 -0800 (PST)
From: John Daniels <johnqdaniels@yahoo.com>
Subject: Determining number of page faults caused by paging out
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <268387.39294.qm@web56003.mail.re3.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I sent this message to kernelnewbies, but no one
responded so I thought I'd see if anyone here could
help me. Is there a way to determine the number of
page faults which occur because a certain page has
been paged out to disk and then back into memory (i.e.
page faults that would have been avoided if the VM
subsystem didn't swap the page to disk)? I know that
major page faults are the ones that require reading
the page from disk, but I think major page faults
would count the pages being brought into memory for
the first time also. I don't think pgpgin gives me
what I want either, though I'm not sure. Maybe I will
need to instrument the kernel to get this information?
I'm sorry if this is too basic a question for this
list.

Thanks,
John


 
____________________________________________________________________________________
Be a PS3 game guru.
Get your game face on with the latest PS3 news and previews at Yahoo! Games.
http://videogames.yahoo.com/platform?platform=120121

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
