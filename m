Subject: Re: [PATCH] Prevent OOM from killing init
Date: Thu, 22 Mar 2001 22:53:39 +0000 (GMT)
In-Reply-To: <3ABA7851.AB080D44@redhat.com> from "Doug Ledford" at Mar 22, 2001 05:10:25 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gDxd-0003Tw-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > How do you return an out of memory error to a C program that is out of memory
> > due to a stack growth fault. There is actually not a language construct for it
> 
> Simple, you reclaim a few of those uptodate buffers.  My testing here has

If you have reclaimable buffers you are not out of memory. If oom is triggered
in that state it is a bug. If you are complaining that the oom killer triggers
at the wrong time then thats a completely unrelated issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
