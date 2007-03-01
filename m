Received: from localhost (localhost.localdomain [127.0.0.1])
	by iona.labri.fr (Postfix) with ESMTP id A2B67101770
	for <linux-mm@kvack.org>; Thu,  1 Mar 2007 19:48:54 +0100 (CET)
Received: from iona.labri.fr ([127.0.0.1])
	by localhost (iona.labri.fr [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id saWI4AAkD2wK for <linux-mm@kvack.org>;
	Thu,  1 Mar 2007 19:48:51 +0100 (CET)
Received: from implementation.famille.thibault.local (d80-170-95-85.cust.tele2.fr [80.170.95.85])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by iona.labri.fr (Postfix) with ESMTP id 6F6D2101763
	for <linux-mm@kvack.org>; Thu,  1 Mar 2007 19:48:51 +0100 (CET)
Received: from samy by implementation.famille.thibault.local with local (Exim 4.63)
	(envelope-from <samuel.thibault@labri.fr>)
	id 1HMqKJ-0000s0-Qp
	for linux-mm@kvack.org; Thu, 01 Mar 2007 19:48:27 +0100
Resent-Message-ID: <20070301184827.GA3346@implementation.famille.thibault.fr>
Resent-To: linux-mm@kvack.org
Date: Thu, 1 Mar 2007 19:11:57 +0100
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: differences between MADV_FREE and MADV_DONTNEED
Message-ID: <20070301181157.GG3550@implementation.labri.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1ek36r9vq.fsf@ebiederm.dsl.xmission.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Eric wrote:
> > We should implement a real MADV_DONTNEED and rename the current one
> > to MADV_FREE, but that's 2.6.17 material.
> 
> We definitely need to check this.  I am fairly certain I have seen
> this conversation before.

Yes, it was back in 2005:
http://marc.theaimsgroup.com/?l=linux-kernel&m=111996850004771&w=2

Nobody took the time to fix it, I filed bug #6282 on bugzilla.kernel.org
some time ago.

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
