From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: bad pmd ffff810000207808(9090909090909090).
References: <874p9biqwj.fsf@duaron.myhome.or.jp>
	<alpine.LNX.1.10.0805061424090.16731@fbirervta.pbzchgretzou.qr>
Date: Tue, 06 May 2008 21:52:58 +0900
In-Reply-To: <alpine.LNX.1.10.0805061424090.16731@fbirervta.pbzchgretzou.qr>
	(Jan Engelhardt's message of "Tue, 6 May 2008 14:35:05 +0200 (CEST)")
Message-ID: <87zlr3zj9x.fsf@duaron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jan Engelhardt <jengelh@medozas.de> writes:

> On Tuesday 2008-05-06 14:00, OGAWA Hirofumi wrote:
>
>>I've found today the following error in syslog. It seems have a strange
>>pattern. And it also happened at a month ago.
>>
>>Any idea for debuging this?
>>
>
> 90 is NOP on x86, perhaps something got rooted?

I see. I'm not sure, but I didn't notice this soon, maybe it worked as
almost usual.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
