Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D46D66B007B
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 16:07:05 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19603.51810.601209.98683@pilspetsen.it.uu.se>
Date: Fri, 17 Sep 2010 22:06:58 +0200
From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: Issue in using mmap on ARM target
In-Reply-To: <AANLkTi=VS34cbaH9TNA9aZ7mVavoTaAiAwMfuRXSxbd8@mail.gmail.com>
References: <AANLkTi=VS34cbaH9TNA9aZ7mVavoTaAiAwMfuRXSxbd8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: naveen yadav <yad.naveen@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

naveen yadav writes:
 > Hi all,
 > 
 > I am facing one issue when executing below progmra on ARM target. The
 > same program work well on X86 host machine,
 > 
 > When execute on Host(x86). the result are as expected.
 > [root@localhost naveen]# ./a.out  0000 b 2
 > /dev/mem opened.
 > Memory mapped at address 0xb7f00000.
 > Value at address 0x0 (0xb7f00000): 0x24
 > Written 0x2; readback 0x2
 > 
 > But when execute on Target:
 > # ./a.out 0 w 20
 > /dev/mem opened.
 > Memory mapped at address 0x40003000.
 > Value at address 0x0 (0x40003000): 0xEA000006
 > Written 0x14; readback 0xEA000006
 > #
 > The value does not change. any idea ....

You might have better luck getting an informed answer by posting
to linux-arm-kernel@lists.infradead.org instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
