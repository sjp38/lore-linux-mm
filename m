Subject: Re: shm_alloc and friends
Date: Thu, 25 May 2000 15:31:38 +0100 (BST)
In-Reply-To: <200005251424.PAA02031@raistlin.arm.linux.org.uk> from "Russell King" at May 25, 2000 03:24:47 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12uyfj-0007vF-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: riel@nl.linux.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Problems:
>  - memsetting the vmalloced area to initialise the pte's.
>    (Note: pte_clear can't be used, because that is expected to be used

Sorry that breaks S/390. You cannot use memset here.

Alan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
