Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA05208
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 19:25:43 -0400
Date: Tue, 6 Apr 1999 01:25:15 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5 
In-Reply-To: <199904052024.QAA29035@pincoya.inf.utfsm.cl>
Message-ID: <Pine.LNX.4.05.9904060124010.447-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Horst von Brand <vonbrand@inf.utfsm.cl>
Cc: Mark Hemment <markhe@sco.COM>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Horst von Brand wrote:

>If you link new pages in at the start (would make sense, IMHO, since they
>will probably be used soon) you can just use the pointer as cookie.

You can have two points of the kernel that are sleeping waiting to alloc
memory for a cache page at the same time.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
