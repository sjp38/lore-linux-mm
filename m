Subject: Re: [PATCH] Prevent OOM from killing init
Date: Thu, 22 Mar 2001 23:40:03 +0000 (GMT)
In-Reply-To: <20010323002752.A5650@win.tue.nl> from "Guest section DW" at Mar 23, 2001 12:27:52 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gEgX-0003Zr-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Guest section DW <dwguest@win.tue.nl>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Even if malloc fails the situation is no different.
> Why do you say so?

Because you will fail on other things - stack overflow, signal delivery,
eventually it will get you. You just cut the odds down. 

> > You can do overcommit avoidance in Linux if you are bored enough to try it.
> 
> Would you accept it as the default? Would Linus?

I'd like to have it there as an option. As to the default - You would have to
see how much applications assume they can overcommit and rely on it. You might
find you need a few Gbytes of swap just to boot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
