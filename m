Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 74A4C6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 14:40:57 -0400 (EDT)
Received: by fxm18 with SMTP id 18so5633336fxm.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:40:48 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106141803.00876.arnd@arndb.de> <op.vw2r3xrj3l0zgt@mnazarewicz-glaptop>
 <201106142030.07549.arnd@arndb.de>
Date: Tue, 14 Jun 2011 20:40:46 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vw2wt8cs3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <201106142030.07549.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

> On Tuesday 14 June 2011 18:58:35 Michal Nazarewicz wrote:
>> Is having support for multiple regions a bad thing?  Frankly,
>> removing this support will change code from reading context passed
>> as argument to code reading context from global variable.  Nothing
>> is gained; functionality is lost.

On Tue, 14 Jun 2011 20:30:07 +0200, Arnd Bergmann wrote:
> What is bad IMHO is making them the default, which forces the board
> code to care about memory management details. I would much prefer
> to have contiguous allocation parameters tuned automatically to just
> work on most boards before we add ways to do board-specific hacks.

I see those as orthogonal problems.  The code can have support for
multiple contexts but by default use a single global context exported
as cma_global variable (or some such).

And I'm not arguing against having =E2=80=9Ccontiguous allocation parame=
ters
tuned automatically to just work on most boards=E2=80=9D.  I just don't =
see
the reason to delete functionality that is already there, does not
add much code and can be useful.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
