Subject: Re: [PATCH] Prevent OOM from killing init
Date: Thu, 22 Mar 2001 23:40:54 +0000 (GMT)
In-Reply-To: <3ABA8B02.F28B333A@redhat.com> from "Doug Ledford" at Mar 22, 2001 06:30:10 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gEhM-0003a2-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Ummm, yeah, that would pretty much be the claim.  Real easy to reproduce too. 
> Take your favorite machine with lots of RAM, run just a handful of startup
> process and system daemons, then log in on a few terminals and do:
> 
> while true; do bonnie -s (1/2 ram); done
> 
> Pretty soon, system daemons will start to die.

Then thats a bug. I assume you've provided Rik with a detailed test case 
already ?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
