Received: from linuxjedi.org (IDENT:root@localhost.localdomain [127.0.0.1])
	by penguin.roanoke.edu (8.11.0/8.11.0) with ESMTP id f2SG8mn12727
	for <linux-mm@kvack.org>; Wed, 28 Mar 2001 11:08:48 -0500
Message-ID: <3AC20CB9.9053F8C8@linuxjedi.org>
Date: Wed, 28 Mar 2001 11:09:29 -0500
From: "David L. Parsley" <parsley@linuxjedi.org>
MIME-Version: 1.0
Subject: report on no-overcommit testing for diskless box
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

So after lots of patching I got my terminal running with no-overcommit. 
X wouldn't start at all - presumably it asks for more memory than is
present and just doesn't use most of it normally.

If the patch becomes available for a recent 2.4.2-ac, I'll try it on a
larger terminal with more memory.  I can still crash a 64MB diskless x
terminal by running xchat full screen (at 1152x900x16bit) - hopefully
no-overcommit will indeed cure bigger machines like this one.

I guess small-mem embedded will need to both patch X _and_ run
no-overcommit for stability.

regards,
	David
-- 
David L. Parsley
Network Administrator
Roanoke College
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
