Message-ID: <3ABE0F32.5255DF30@evision-ventures.com>
Date: Sun, 25 Mar 2001 17:30:58 +0200
From: Martin Dalecki <dalecki@evision-ventures.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <E14gVQf-00056B-00@the-village.bc.nu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> 
> > That depends what you mean by "must not". If it's your missile guidance
> > system, aircraft autopilot or life support system, the system must not run
> > out of memory in the first place. If the system breaks down badly, killing
> > init and thus panicking (hence rebooting, if the system is set up that
> > way) seems the best approach.
> 
> Ultra reliable systems dont contain memory allocators. There are good reasons
> for this but the design trade offs are rather hard to make in a real world
> environment

I esp. they run on CPU's without a stack or what?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
