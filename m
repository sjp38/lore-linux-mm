Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 638316B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 07:10:29 -0500 (EST)
Received: by wyi11 with SMTP id 11so2470659wyi.14
        for <linux-mm@kvack.org>; Thu, 17 Nov 2011 04:10:26 -0800 (PST)
Date: Thu, 17 Nov 2011 12:10:18 +0000
From: Dave Martin <dave.martin@linaro.org>
Subject: Re: Crash when memset of shared mapped memory in ARM
Message-ID: <20111117121017.GA3044@localhost.localdomain>
References: <CAJ8eaTzOtgMzcZeRr6f=+WhtsykK1NZraOGBPoqGncwcAGcTyQ@mail.gmail.com>
 <20111116084547.GG9581@n2100.arm.linux.org.uk>
 <20111116115435.GI4942@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111116115435.GI4942@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, naveen yadav <yad.naveen@gmail.com>

On Wed, Nov 16, 2011 at 11:54:35AM +0000, Will Deacon wrote:
> (Replying to Russell so as to lose the -request addresses)
> 
> On Wed, Nov 16, 2011 at 08:45:47AM +0000, Russell King - ARM Linux wrote:
> > Please do not spam mailing lists -request addresses when you post.  The
> > -request addresses are there for you to give the mailing list software
> > _instructions_ on what to do with your subscription.  It is not for
> > posts to the mailing list.
> 
> For what it's worth, I was brave/daft enough to compile and run the testcase
> with an -rc1 kernel and Linaro 11.09 filesystem on the quad A9 Versatile
> Express:
> 
> root@dancing-fool:~# ./yad
> mmap: addr 0x20000000
> root@dancing-fool:~# ./yad
> shm_open: File exists
> mmap: addr 0x20000000
> 
> Looks like I'm missing the fireworks, despite the weirdy MAP_SHARED |
> MAP_FIXED mmap flags.

I did't see any problem on a random 3.1-rc4 kernel either on A9...

(Since when was MAP_SHARED "weirdy"...?)

Cheers
---Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
