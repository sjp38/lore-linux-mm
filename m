Received: (from vvadapalli@localhost)
	by mili.razafoundries.com (8.11.6/8.11.6) id h5H06W326655
	for linux-mm@kvack.org; Mon, 16 Jun 2003 17:06:32 -0700
Message-ID: <200306170006.h5H06W326655@mili.razafoundries.com>
From: Venu Vadapalli <vvadapalli@razamicroelectronics.com>
Subject: Re: use_mm/unuse_mm correctness
Date: Mon, 16 Jun 2003 17:06:32 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Do kernel threads have 'mm'? I thought they inherit the active_mm from the
previously running task or in this case just use the desired mm...


This email message (including attachments) contains Company Proprietary
and/or Confidential Information and is intended only for the addressee.  Any
unauthorized review, use, disclosure or distribution is prohibited.  If you
are not the intended recipient, please contact the sender by reply email and
destroy all copies of the original message.  Thank you. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
