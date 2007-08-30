Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2a07.orange.fr (SMTP Server) with ESMTP id 45C117000098
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 16:07:02 +0200 (CEST)
Received: from awak.dyndns.org (AGrenoble-257-1-54-65.w86-206.abo.wanadoo.fr [86.206.29.65])
	by mwinf2a07.orange.fr (SMTP Server) with ESMTP id 36F687000081
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 16:07:02 +0200 (CEST)
Subject: Re: speeding up swapoff
From: Xavier Bestel <xavier.bestel@free.fr>
In-Reply-To: <46D6CC35.90207@aitel.hist.no>
References: <fa.j/pO3mTWDugTdvZ3XNr9XpvgzPQ@ifi.uio.no>
	 <fa.ed9fasZXOwVCrbffkPQTX7G3a7g@ifi.uio.no>
	 <fa./NZA3biuO1+qW5pW8ybdZMDWcZs@ifi.uio.no> <46D61F48.5090406@shaw.ca>
	 <46D6CC35.90207@aitel.hist.no>
Content-Type: text/plain
Date: Thu, 30 Aug 2007 16:06:55 +0200
Message-Id: <1188482815.1131.374.camel@frg-rhel40-em64t-04>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helge.hafting@aitel.hist.no>
Cc: Robert Hancock <hancockr@shaw.ca>, Daniel Drake <ddrake@brontes3d.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-30 at 15:55 +0200, Helge Hafting wrote:
> If the swap device is full, then there is no need for random
> seeks as the swap pages can be read in disk order.

If the swap file is full, you probably have a machine dead into a swap
storm.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
