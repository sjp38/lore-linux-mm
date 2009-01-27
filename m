Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F09EB6B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 15:16:48 -0500 (EST)
Subject: Re: marching through all physical memory in software
References: <497DD8E5.1040305@nortel.com>
	<20090126075957.69b64a2e@infradead.org> <497F5289.404@nortel.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 27 Jan 2009 12:16:52 -0800
In-Reply-To: <497F5289.404@nortel.com> (Chris Friesen's message of "Tue\, 27 Jan 2009 12\:29\:29 -0600")
Message-ID: <m1vds0bj2j.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, Doug Thompson <norsk5@yahoo.com>, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

"Chris Friesen" <cfriesen@nortel.com> writes:

> Arjan van de Ven wrote:
>> On Mon, 26 Jan 2009 09:38:13 -0600
>> "Chris Friesen" <cfriesen@nortel.com> wrote:
>>
>>> Someone is asking me about the feasability of "scrubbing" system
>>> memory by accessing each page and handling the ECC faults.
>>>
>>
>> Hi,
>>
>> I would suggest that you look at the "edac" subsystem, which tries to
>> do exactly this....


> edac appears to currently be able to scrub the specific page where the fault
> occurred.  This is a useful building block, but doesn't provide the ability to
> march through all of physical memory.

Well that is the tricky part.  The rest is simply finding which physical
addresses are valid.  Either by querying the memory controller or looking
at the range the BIOS gave us.

That part should not be too hard.  I think it simply has not been implemented
yet as most ECC chipsets implement this in hardware today.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
