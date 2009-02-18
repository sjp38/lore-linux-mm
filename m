Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC916B0089
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 05:53:25 -0500 (EST)
Received: from rly22g.srv.mailcontrol.com (localhost.localdomain [127.0.0.1])
	by rly22g.srv.mailcontrol.com (MailControl) with ESMTP id n1IArB6i001906
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 10:53:12 GMT
Received: from submission.mailcontrol.com (submission.mailcontrol.com [86.111.216.190])
	by rly22g.srv.mailcontrol.com (MailControl) id n1IAqC5Z027359
	for linux-mm@kvack.org; Wed, 18 Feb 2009 10:52:12 GMT
Message-ID: <499BE83D.6040406@csr.com>
Date: Wed, 18 Feb 2009 10:51:41 +0000
From: David Vrabel <david.vrabel@csr.com>
MIME-Version: 1.0
Subject: Re: [patch 5/7] usb: use kzfree()
References: <20090217182615.897042724@cmpxchg.org> <20090217184136.097882343@cmpxchg.org>
In-Reply-To: <20090217184136.097882343@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

This is in the WUSB code so:

Acked-by: David Vrabel <david.vrabel@csr.com>

David
-- 
David Vrabel, Senior Software Engineer, Drivers
CSR, Churchill House, Cambridge Business Park,  Tel: +44 (0)1223 692562
Cowley Road, Cambridge, CB4 0WZ                 http://www.csr.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
