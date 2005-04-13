Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id j3DHZss4005597
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2005 10:35:55 -0700
Received: from bix (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id j3DHZs2A005310
	for <linux-mm@kvack.org>; Wed, 13 Apr 2005 10:35:54 -0700
Date: Wed, 13 Apr 2005 10:35:46 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bug 4481] hang at boot from kernels 2.6.9 and above
Message-Id: <20050413103546.789a9290.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Strange.  Keeps hitting buffered_rmqueue()'s

	BUG_ON(bad_range(zone, page));

during bootup.


Begin forwarded message:

Date: Wed, 13 Apr 2005 07:18:08 -0700
From: bugme-daemon@osdl.org
To: akpm@digeo.com
Subject: [Bug 4481] hang at boot from kernels 2.6.9 and above


http://bugme.osdl.org/show_bug.cgi?id=4481





------- Additional Comments From borge3@esial.uhp-nancy.fr  2005-04-13 07:18 -------
Created an attachment (id=4911)
 --> (http://bugme.osdl.org/attachment.cgi?id=4911&action=view)
another dmesg


------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
