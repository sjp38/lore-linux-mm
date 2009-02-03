Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7EF5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 09:32:38 -0500 (EST)
Message-ID: <4988555B.8010408@nortel.com>
Date: Tue, 03 Feb 2009 08:31:55 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: marching through all physical memory in software
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org>            <49873B99.3070405@nortel.com> <37985.1233614746@turing-police.cc.vt.edu>
In-Reply-To: <37985.1233614746@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, Pavel Machek <pavel@suse.cz>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Valdis.Kletnieks@vt.edu wrote:
> On Mon, 02 Feb 2009 12:29:45 CST, Chris Friesen said:
> 
>>The next question is who handles the conversion of the various different 
>>arch-specific BIOS mappings to a standard format that we can feed to the 
>>background "scrub" code.  Is this something that belongs in the edac 
>>memory controller code, or would it live in /arch/foo somewhere?
> 
> 
> If it's intended to be something basically stand-alone that doesn't require
> an actual EDAC chipset, it should probably live elsewhere.  Otherwise, you get
> into the case of people who don't enable it because they "know" their hardware
> doesn't have an EDAC ability, even if they *could* benefit from the function.
> 
> On the other hand, if it's an EDAC-only thing, maybe under drivers/edac/$ARCH?

I don't see anything in the name of EDAC that implies hardware only...a 
software memory scrub could be considered "error detection and 
correction".  Might have to update the config help text though.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
