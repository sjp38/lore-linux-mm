Message-ID: <3BCB5CF6.5020607@zytor.com>
Date: Mon, 15 Oct 2001 15:02:30 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: More questions...
References: <20011015215654.16878.qmail@web14304.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:

> 
>>b) Is there an architecture-independent way to
>>determine if a page fault
>>was due to a read or write operation?  On i386 I can
>>look at the %cr2
>>value in the sigcontext, but I'd prefer to do
>>something less arch-specific...
>>
> 
> The last parameter to handle_mm_fault() ...
> 

How do I determine it *in userspace*?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
