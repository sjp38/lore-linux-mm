Message-ID: <3BCB5F20.5000609@zytor.com>
Date: Mon, 15 Oct 2001 15:11:44 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: More questions...
References: <20011015215654.16878.qmail@web14304.mail.yahoo.com> <3BCB5CF6.5020607@zytor.com> <20011016000836.A28390@gruyere.muc.suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Kanoj Sarcar <kanojsarcar@yahoo.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> On Mon, Oct 15, 2001 at 03:02:30PM -0700, H. Peter Anvin wrote:
>
>>How do I determine it *in userspace*?
>>
>
> No portable way. The portable API (siginfo_t) doesn't supply it ATM.
> In theory it could be put into si_errno, but no current kernel does that.
> Most architectures will likely gives it to you in some form in the
> arch specific signal frame however.
>


IWBNI it could be added, assuming it can be done without breaking existing
applications (perhaps a flag could be snuck in somewhere.)  I can write
the code so that if the information is present, it uses it; otherwise the
worst that can happen is having to do the two-step NONE -> READ ->
READ|WRITE transition, as it currently is.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
