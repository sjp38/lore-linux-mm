Subject: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <1026426511.1244.321.camel@sinai>
References: <1026426511.1244.321.camel@sinai>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 12 Jul 2002 10:30:39 -0700
Message-Id: <1026495039.1750.379.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

A version of Alan's strict VM overcommit for the stock VM is available
for 2.4.19-rc1 at:

	ftp://ftp.kernel.org/pub/linux/kernel/people/rml/vm/strict-overcommit/2.4/vm-strict-overcommit-rml-2.4.19-rc1-1.patch

This is the same code I posted yesterday (see "[PATCH] strict VM
overcommit for" from 20020711) except for the stock non-rmap VM in 2.4.

Hugh Dickins sent me a few fixes, mostly for shmfs accounting, that he
recently discovered... that code is not yet merged but will be, probably
after this weekend.

I still encourage testing and comments.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
