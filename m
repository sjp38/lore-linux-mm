From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102270921.BAA10874@google.engr.sgi.com>
Subject: Re: 2.5 page cache improvement idea
Date: Tue, 27 Feb 2001 01:21:24 -0800 (PST)
In-Reply-To: <200102270905.f1R958I03268@eng1.sequent.com> from "Gerrit Huizenga" at Feb 27, 2001 01:05:08 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerrit@us.ibm.com
Cc: Ben LaHaise <bcrl@redhat.com>, Chuck Lever <Charles.Lever@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> That change is platform specific, isn't it?  I thought there was also

Yes, completely. 

> a recent IA-64 patch in progress for the same thing, but I might

Yes, a couple of people are planning on attempting that soon, we will
see when someone gets to it.

> be mistaken.  I'm thinking that it would be useful if the machine
> independent code supported kernel text replication as well as

There *might* be some changes needed for kernel text replication
(mostly to deal with /proc/kcore type of things), but for the most
part, this is really arch specific. You know, those types of things 
that tend to show up mostly in production environment, rather than 
at the prototype/testing stages.

> shared/read-only text replication for user level applications.
>

User level apps, now thats a different beast. I *suspect* a lot
of work needs to be put into replication heuristics before you can
reap benefits from it. Currently, this is in my pet numa priority list,
but not one of the top few.

Kanoj

> gerrit
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
