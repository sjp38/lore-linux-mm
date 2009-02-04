Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D1AEA6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 11:04:15 -0500 (EST)
Message-ID: <4989BC67.3090708@nortel.com>
Date: Wed, 04 Feb 2009 10:03:51 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: marching through all physical memory in software
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org> <49873B99.3070405@nortel.com> <37985.1233614746@turing-police.cc.vt.edu> <4988555B.8010408@nortel.com> <20090203222501.GC2857@elf.ucw.cz>
In-Reply-To: <20090203222501.GC2857@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@suse.cz>
Cc: Valdis.Kletnieks@vt.edu, "Eric W. Biederman" <ebiederm@xmission.com>, Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:

>>I don't see anything in the name of EDAC that implies hardware only...a  
>>software memory scrub could be considered "error detection and  
>>correction".  Might have to update the config help text though.
> 
> 
> Software memory scrub would no longer be a "driver" :-). So it should
> go into kernel/scrub or mm/scrub or maybe mm/edac or something.

True enough.  In that case, something under "mm" makes more sense to me 
than something under "kernel".

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
