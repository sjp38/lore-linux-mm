Date: Tue, 6 May 2008 21:50:15 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: bad pmd ffff810000207808(9090909090909090).
Message-ID: <20080506195014.GS8474@1wt.eu>
References: <874p9biqwj.fsf@duaron.myhome.or.jp> <alpine.LNX.1.10.0805061424090.16731@fbirervta.pbzchgretzou.qr> <87zlr3zj9x.fsf@duaron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zlr3zj9x.fsf@duaron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Engelhardt <jengelh@medozas.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 09:52:58PM +0900, OGAWA Hirofumi wrote:
> Jan Engelhardt <jengelh@medozas.de> writes:
> 
> > On Tuesday 2008-05-06 14:00, OGAWA Hirofumi wrote:
> >
> >>I've found today the following error in syslog. It seems have a strange
> >>pattern. And it also happened at a month ago.
> >>
> >>Any idea for debuging this?
> >>
> >
> > 90 is NOP on x86, perhaps something got rooted?
> 
> I see. I'm not sure, but I didn't notice this soon, maybe it worked as
> almost usual.

I got immediate same feeling as Jan here. It looks very much like someone
has tried to inject code into your system. The problem is that you don't
know if this finally succeeded. Maybe some backdoor is now installed in
your kernel. If I were you, I would isolate the machine, reboot it on CD
and check MD5s (particularly the ones of the kernel and modules) before
rebooting it.

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
