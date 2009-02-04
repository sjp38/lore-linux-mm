Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7EC006B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:47:42 -0500 (EST)
Message-ID: <4989C6A8.5050906@mvista.com>
Date: Wed, 04 Feb 2009 09:47:36 -0700
From: Dave Jiang <djiang@mvista.com>
MIME-Version: 1.0
Subject: Re: marching through all physical memory in software
References: <715599.77204.qm@web50111.mail.re2.yahoo.com>	<m1wscc7fop.fsf@fess.ebiederm.org> <49873B99.3070405@nortel.com>	<37985.1233614746@turing-police.cc.vt.edu>	<4988555B.8010408@nortel.com> <20090203222501.GC2857@elf.ucw.cz>
In-Reply-To: <20090203222501.GC2857@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@suse.cz>
Cc: Chris Friesen <cfriesen@nortel.com>, ncunningham-lkml@crca.org.au, Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>, Doug Thompson <norsk5@yahoo.com>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

There may be generic code, but the actual scrubbing can be architecture 
specific. You have to atomically read and write back. And each arch has 
different way of handling that. See arch/X/include/asm/edac.h

Pavel Machek wrote:
> Software memory scrub would no longer be a "driver" :-). So it should
> go into kernel/scrub or mm/scrub or maybe mm/edac or something.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
