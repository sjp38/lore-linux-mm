Subject: Re: [PATCH] Prevent OOM from killing init
Date: Fri, 23 Mar 2001 22:21:07 +0000 (GMT)
In-Reply-To: <Pine.LNX.4.30.0103232159560.13864-100000@fs131-224.f-secure.com> from "Szabolcs Szakacsits" at Mar 23, 2001 10:09:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14gZvi-0005YW-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Guest section DW <dwguest@win.tue.nl>, Stephen Clouse <stephenc@theiqgroup.com>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > and rely on it. You might find you need a few Gbytes of swap just to
> > boot
> 
> Seems a bit exaggeration ;) Here are numbers,

NetBSD is if I remember rightly still using a.out library styles. 

> 6-50% more VM and the performance hit also isn't so bad as it's thought
> (Eduardo Horvath sent a non-overcommit patch for Linux about one year
> ago).

The Linux performance hit would be so close to zero you shouldnt be able to
measure it - or it was in 1.2 anyway
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
