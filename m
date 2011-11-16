Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFF66B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 06:54:43 -0500 (EST)
Date: Wed, 16 Nov 2011 11:54:35 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: Crash when memset of shared mapped memory in ARM
Message-ID: <20111116115435.GI4942@mudshark.cambridge.arm.com>
References: <CAJ8eaTzOtgMzcZeRr6f=+WhtsykK1NZraOGBPoqGncwcAGcTyQ@mail.gmail.com>
 <20111116084547.GG9581@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111116084547.GG9581@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: naveen yadav <yad.naveen@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

(Replying to Russell so as to lose the -request addresses)

On Wed, Nov 16, 2011 at 08:45:47AM +0000, Russell King - ARM Linux wrote:
> Please do not spam mailing lists -request addresses when you post.  The
> -request addresses are there for you to give the mailing list software
> _instructions_ on what to do with your subscription.  It is not for
> posts to the mailing list.

For what it's worth, I was brave/daft enough to compile and run the testcase
with an -rc1 kernel and Linaro 11.09 filesystem on the quad A9 Versatile
Express:

root@dancing-fool:~# ./yad
mmap: addr 0x20000000
root@dancing-fool:~# ./yad
shm_open: File exists
mmap: addr 0x20000000

Looks like I'm missing the fireworks, despite the weirdy MAP_SHARED |
MAP_FIXED mmap flags.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
