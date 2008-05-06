Date: Wed, 7 May 2008 01:21:05 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: bad pmd ffff810000207808(9090909090909090).
Message-ID: <20080506232105.GA22457@1wt.eu>
References: <874p9biqwj.fsf@duaron.myhome.or.jp> <alpine.LNX.1.10.0805061424090.16731@fbirervta.pbzchgretzou.qr> <87zlr3zj9x.fsf@duaron.myhome.or.jp> <20080506195014.GS8474@1wt.eu> <87abj3nibc.fsf@duaron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87abj3nibc.fsf@duaron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Engelhardt <jengelh@medozas.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 08:06:47AM +0900, OGAWA Hirofumi wrote:
> Willy Tarreau <w@1wt.eu> writes:
> 
> >> I see. I'm not sure, but I didn't notice this soon, maybe it worked as
> >> almost usual.
> >
> > I got immediate same feeling as Jan here. It looks very much like someone
> > has tried to inject code into your system. The problem is that you don't
> > know if this finally succeeded. Maybe some backdoor is now installed in
> > your kernel. If I were you, I would isolate the machine, reboot it on CD
> > and check MD5s (particularly the ones of the kernel and modules) before
> > rebooting it.
> 
> Hm.. I've checked md5sum as far as I can do (/var/lib/dpkg/info/*.md5sums).
> It seems to have no difference except data files.
> 
> And this machine is in back of firewall of other machine, and the kernel
> is builded from source each every day or a hour or such.
> 
> So, it is unlikely...

OK. At least it was worth checking!

Regards,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
