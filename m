Message-Id: <200301281749.MAA12566@boo-mda02.boo.net>
From: jasonp@boo.net
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
Date: Tue, 28 Jan 2003 17:49:37 GMT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> If a benefit cannot be show on some sort of semi-realistic workload,
> it's probably not worth it, IMHO.

With the present state of the patch my own limited tests don't uncover any
speedups at all on my x86 test machine. For the Alpha with 2MB cache (and the 
2.4 patch) there are measurable speedups; number-crunching benchmarks show it 
the most.

jasonp

---------------------------------------------
This message was sent using Endymion MailMan.
http://www.endymion.com/products/mailman/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
