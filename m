Received: from pd2mr3so.prod.shaw.ca (pd2mr3so-ser.prod.shaw.ca [10.0.141.108])
 by l-daemon (iPlanet Messaging Server 5.1 HotFix 0.8 (built May 12 2002))
 with ESMTP id <0H0300GA97BK9O@l-daemon> for linux-mm@kvack.org; Tue,
 30 Jul 2002 18:14:08 -0600 (MDT)
Received: from pn2ml9so.prod.shaw.ca (pn2ml9so-qfe0.prod.shaw.ca [10.0.121.7])
 by l-daemon (iPlanet Messaging Server 5.1 HotFix 0.8 (built May 12 2002))
 with ESMTP id <0H0300H6N7BKI2@l-daemon> for linux-mm@kvack.org; Tue,
 30 Jul 2002 18:14:08 -0600 (MDT)
Received: from W800 (h24-65-211-20.cg.shawcable.net [24.65.211.20])
 by l-daemon (iPlanet Messaging Server 5.1 HotFix 0.8 (built May 12 2002))
 with SMTP id <0H03002FM7BJJM@l-daemon> for linux-mm@kvack.org; Tue,
 30 Jul 2002 18:14:08 -0600 (MDT)
Date: Tue, 30 Jul 2002 18:12:56 -0600
From: Nathan Friess <natmanz@shaw.ca>
Subject: how to tell which pages were allocated from kernel?
Message-id: <000901c23827$05604370$0201010a@W800>
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Please CC to me, as I'm not subscribed to the list.

Short version:

I know how to see a list of all memory pages in the variable mem_map, but
how do I tell which pages are allocated for the kernel, and which pages are
allocated for user space processes?

Long version:

I recently learned about a project (patch) that gives the linux kernel the
ability to suspend to disk.  I'm planning to make some changes to see if I
can improve it's performance on my laptop.  I've looked through the code and
relevent protions of the kernel, and googled for some help, but I still
don't seem to have all of the information I'm looking for.  In particular,
currently the suspending code just allocates a new page for every existing
one, and copies every existing page to a newly allocated page, then writes
all of the newly allocated pages to swap.  As a result, the suspend requires
that at least 1/2 of the physical RAM is free, so these temporary pages can
be allocated in RAM before writing to swap.

If there is some way that I could tell which pages belong to user space
processes, then I could write those pages directly to swap without copying
them.  So, how would I find out where they came from?  I don't see any field
in the page struct to indicate this, although I did notice that there is a
#define called GFP_USER which I believe is passed to the alloc functions
when the kernel allocates space on behalf of a user process.  If need be, I
might try to add something so that I could keep track of the pages, like add
a field to the page struct.

Sorry if this seems trivial, but I figure I can spend more hours searching
the web and mm code, or I can just ask the experts directly.

Thanks,

Nathan Friess


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
