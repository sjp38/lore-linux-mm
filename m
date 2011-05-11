Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEE96B0011
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:36:21 -0400 (EDT)
Date: Wed, 11 May 2011 20:36:02 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Fwd: [ARM]crash on 2.6.35.11
Message-ID: <20110511193602.GK5315@n2100.arm.linux.org.uk>
References: <BANLkTimLd-qY-OeKqnf2EoTfvAHWQZVchw@mail.gmail.com> <BANLkTi=oZ0Mr33rL=QNmzDuaKLNezoKBXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=oZ0Mr33rL=QNmzDuaKLNezoKBXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: naveen yadav <yad.naveen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm <linux-mm@kvack.org>, linux newbie <linux.newbie79@gmail.com>, linux-kernel@vger.kernel.org

On Wed, May 04, 2011 at 03:46:55PM +0530, naveen yadav wrote:
> Attaching test case
> 
> Dear all,
> 
> We are running linux kernel 2.6.35.11 on Cortex a-8. when I run a
> simple program expect to give oom.
>  But it crash with following crash log

You need to include the memory layout information - eg, the boot log,
and /proc/iomem.  Also are you using sparsemem?  If so, how is it
configured?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
