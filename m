Date: Thu, 7 Aug 2003 12:51:27 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Free list initialization
In-Reply-To: <2110.128.2.222.155.1060209130.squirrel@webmail.andrew.cmu.edu>
Message-ID: <Pine.LNX.4.53.0308071250180.30544@skynet>
References: <2110.128.2.222.155.1060209130.squirrel@webmail.andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anand Eswaran <aeswaran@andrew.cmu.edu>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Aug 2003, Anand Eswaran wrote:

>   Could anybody point me out to the part of the mm code where the  zone
> free-lists are initialized to the remaining system memory  just
> subsequent to setting up of the zone structures .

Read:

http://www.csn.ul.ie/~mel/projects/vm/guide/html/understand/node42.html

and then

http://www.csn.ul.ie/~mel/projects/vm/guide/html/code/node9.html#SECTION00450300000000000000

-- 
Mel Gorman
http://www.csn.ul.ie/~mel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
