Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA12900
	for <linux-mm@kvack.org>; Tue, 25 Nov 1997 14:47:27 -0500
Message-Id: <m0xaQny-0005FCC@lightning.swansea.linux.org.uk>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: Pageable pagetables.
Date: Tue, 25 Nov 1997 19:37:54 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.971125181918.7764A-100000@pc7537.hil.siemens.at> from "Ingo Molnar" at Nov 25, 97 06:20:05 pm
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@pc7537.hil.siemens.at>
Cc: H.H.vanRiel@fys.ruu.nl, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I've had some mails about whether Linux could be made
> > to swap pagetables.
> also, COW-ing pagetables seems to be worthwhile as well?

If you do this you must turn it off on some B step pentiums. Yep its
errata time again
