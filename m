Date: Tue, 16 Oct 2001 00:15:33 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: More questions...
Message-ID: <20011016001533.A30579@gruyere.muc.suse.de>
References: <20011015215654.16878.qmail@web14304.mail.yahoo.com> <3BCB5CF6.5020607@zytor.com> <20011016000836.A28390@gruyere.muc.suse.de> <3BCB5F20.5000609@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BCB5F20.5000609@zytor.com>; from hpa@zytor.com on Mon, Oct 15, 2001 at 03:11:44PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@suse.de>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 15, 2001 at 03:11:44PM -0700, H. Peter Anvin wrote:
>
> IWBNI it could be added, assuming it can be done without breaking existing
> applications (perhaps a flag could be snuck in somewhere.)  I can write
> the code so that if the information is present, it uses it; otherwise the
> worst that can happen is having to do the two-step NONE -> READ ->
> READ|WRITE transition, as it currently is.

At least on linux si_errno on signals should be always 0. I doubt anything
depends on that. I don't know if that is true on other operating systems
however. Single Unix has nothing to say about it as far as I can see.

You don't need a flag. Just use it when it is != 0.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
