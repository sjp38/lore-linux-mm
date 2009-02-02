Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3475F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 13:30:14 -0500 (EST)
Message-ID: <49873B99.3070405@nortel.com>
Date: Mon, 02 Feb 2009 12:29:45 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: marching through all physical memory in software
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org>
In-Reply-To: <m1wscc7fop.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, Pavel Machek <pavel@suse.cz>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:

> Thinking about it.  We only care about memory the kernel is using so the memory
> maps the BIOS supplies the kernel should be sufficient.  We have weird corner
> cases like ACPI but not handling those in the first pass and getting
> something working should be fine.

Agreed.

The next question is who handles the conversion of the various different 
arch-specific BIOS mappings to a standard format that we can feed to the 
background "scrub" code.  Is this something that belongs in the edac 
memory controller code, or would it live in /arch/foo somewhere?

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
