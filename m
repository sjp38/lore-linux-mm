Message-ID: <20011015215654.16878.qmail@web14304.mail.yahoo.com>
Date: Mon, 15 Oct 2001 14:56:54 -0700 (PDT)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: More questions...
In-Reply-To: <3BCB594E.60004@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


>
> b) Is there an architecture-independent way to
> determine if a page fault
> was due to a read or write operation?  On i386 I can
> look at the %cr2
> value in the sigcontext, but I'd prefer to do
> something less arch-specific...
>

The last parameter to handle_mm_fault() ...

Kanoj

__________________________________________________
Do You Yahoo!?
Make a great connection at Yahoo! Personals.
http://personals.yahoo.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
