Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5SGfCrp136872
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 16:41:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5SGfBwn921758
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:11 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5SGfBpj016532
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:11 +0200
Message-Id: <20070628164049.118610355@de.ibm.com>
Date: Thu, 28 Jun 2007 18:40:49 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 0/6] resend: guest page hinting version 5.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Greetings,
after Carsten pitched CMM2 on the kvm mini summit here is a repost
of version 5 of the guest page hinting patches. The code is still
the same but has been adapted to the latest git level.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
