Date: Wed, 24 Jan 2001 09:14:02 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <y7rk87leptf.fsf@sytry.doc.ic.ac.uk>
References: <Pine.GSO.4.10.10101231903380.14027-100000@zeus.fh-brandenburg.de>
Subject: Re: ioremap_nocache problem?
Message-Id: <20010124151115Z131195-222+36@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Wragg <dpw@doc.ic.ac.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from David Wragg <dpw@doc.ic.ac.uk> on 24 Jan 2001 00:50:20
+0000


> (x86 processors with PAT and IA64 can set write-combining through page
> flags.  x86 processors with MTRRs but not PAT would need a more
> elaborate implementation for write-combining.)

What is PAT?  I desperately need to figure out how to turn on write combining
on a per-page level.  I thought I had to use MTRRs, but now you're saying I can
use this "PAT" thing instead.  Please explain!


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
