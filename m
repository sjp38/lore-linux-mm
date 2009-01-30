Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6BC6B0083
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 15:20:54 -0500 (EST)
Message-ID: <49836114.1090209@buttersideup.com>
Date: Fri, 30 Jan 2009 20:20:36 +0000
From: Tim Small <tim@buttersideup.com>
MIME-Version: 1.0
Subject: Re: marching through all physical memory in software
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org>
In-Reply-To: <m1wscc7fop.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Friesen <cfriesen@nortel.com>, Pavel Machek <pavel@suse.cz>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> A background software scrubber simply has the job of rewritting memory
> to it's current content so that the data and the ecc check bits are
> guaranteed to be in sync

Don't you just need to READ memory?  The memory controller hardware 
takes care of the rest in the vast majority of cases.

You only need to rewrite RAM if a correctable error occurs, and the 
chipset doesn't support automatic write-back of the corrected value (a 
different problem altogether...).  The actual memory bits themselves are 
refreshed by the hardware quite frequently (max of every 64ms for DDR2, 
I believe)...

Cheers,

Tim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
