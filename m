Date: Tue, 6 May 2008 14:35:05 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: bad pmd ffff810000207808(9090909090909090).
In-Reply-To: <874p9biqwj.fsf@duaron.myhome.or.jp>
Message-ID: <alpine.LNX.1.10.0805061424090.16731@fbirervta.pbzchgretzou.qr>
References: <874p9biqwj.fsf@duaron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 2008-05-06 14:00, OGAWA Hirofumi wrote:

>Hi,
>
>I've found today the following error in syslog. It seems have a strange
>pattern. And it also happened at a month ago.
>
>Any idea for debuging this?
>

90 is NOP on x86, perhaps something got rooted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
