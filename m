Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06556
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 13:53:47 -0400
Date: Thu, 23 Jul 1998 10:53:09 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Important - MM panic in 2.1.109 [PATCH + Oops]
In-Reply-To: <199807231709.SAA13482@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980723105231.6619A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Michael L. Galbraith" <mikeg@weiden.de>, Itai Nahshon <nahshon@actcom.co.il>, linux kernel list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 23 Jul 1998, Stephen C. Tweedie wrote:
> 
> However, there's an alternative fix in mm/mmap.c:

[ patch removed ]

Applied. I always prefer to fix bug by removing code rather than adding it
;) 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
