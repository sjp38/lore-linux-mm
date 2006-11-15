Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id kAFHvZHK237602
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 17:57:35 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAFI0p3s2793526
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 19:00:51 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAFHvYk9014764
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 18:57:35 +0100
Date: Wed, 15 Nov 2006 18:54:47 +0100
From: Christian Krafft <krafft@de.ibm.com>
Subject: [patch 0/2] fix bugs while booting on NUMA system where some nodes
 have no mem
Message-ID: <20061115185447.3bcc1f6e@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

The following patches are fixing two problems that showed up
while booting a NUMA system where memory was limited to the first node.
Please cc me for comments as I am not subscribed.

cheers,
Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
