Received: from CONVERSION-DAEMON.jhuml3.jhu.edu by jhuml3.jhu.edu
 (PMDF V6.0-24 #47345) id <0G3100K01YXZK6@jhuml3.jhu.edu> for
 linux-mm@kvack.org; Thu, 26 Oct 2000 15:46:47 -0400 (EDT)
Received: from aa.eps.jhu.edu (aa.eps.jhu.edu [128.220.24.92])
 by jhuml3.jhu.edu (PMDF V6.0-24 #47345)
 with ESMTP id <0G3100K81YXY00@jhuml3.jhu.edu> for linux-mm@kvack.org; Thu,
 26 Oct 2000 15:46:47 -0400 (EDT)
Date: Thu, 26 Oct 2000 15:45:20 -0400 (EDT)
From: afei@jhu.edu
Subject: Re: page fault.
In-reply-to: 
        <Pine.LNX.4.10.10010270739550.5849-100000@agastya.serc.iisc.ernet.in>
Message-id: <Pine.GSO.4.05.10010261543320.16149-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M.Jagadish Kumar" <jagadish@rishi.serc.iisc.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 27 Oct 2000, M.Jagadish Kumar wrote:

> hello,
> Is there any way in which i can know when the pagefault occured,
> i mean at what instruction of my program execution.
> Does OS provide any support. This would help me to improve my program.
> thanx
> jagadish
The way I use is to use oops message and System.map to locate the
subroutine where the oops occured. To find the exact line where the oops
occured, you need to either check assemble code or use more complicated
kernel debug technique. I think Rik covered some in his kernel debug
slides.

Fei

> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
