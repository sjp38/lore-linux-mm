Subject: Re: [PATCH] Prevent OOM from killing init
Date: Fri, 23 Mar 2001 17:32:46 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.30.0103231721480.4103-100000@dax.joh.cam.ac.uk> from "James A. Sutherland" at Mar 23, 2001 05:26:22 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gVQf-00056B-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> That depends what you mean by "must not". If it's your missile guidance
> system, aircraft autopilot or life support system, the system must not run
> out of memory in the first place. If the system breaks down badly, killing
> init and thus panicking (hence rebooting, if the system is set up that
> way) seems the best approach.

Ultra reliable systems dont contain memory allocators. There are good reasons
for this but the design trade offs are rather hard to make in a real world
environment

Solving the trivial overcommit case is not a difficult task but since I don't
believe it is needed I'll wait for those who moan so loudly to do it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
