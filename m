Date: Tue, 16 Oct 2001 00:08:36 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: More questions...
Message-ID: <20011016000836.A28390@gruyere.muc.suse.de>
References: <20011015215654.16878.qmail@web14304.mail.yahoo.com> <3BCB5CF6.5020607@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BCB5CF6.5020607@zytor.com>; from hpa@zytor.com on Mon, Oct 15, 2001 at 03:02:30PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Kanoj Sarcar <kanojsarcar@yahoo.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 15, 2001 at 03:02:30PM -0700, H. Peter Anvin wrote:
> How do I determine it *in userspace*?

No portable way. The portable API (siginfo_t) doesn't supply it ATM.
In theory it could be put into si_errno, but no current kernel does that.
Most architectures will likely gives it to you in some form in the
arch specific signal frame however.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
