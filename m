Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA14135
	for <linux-mm@kvack.org>; Fri, 21 Feb 2003 18:09:22 -0800 (PST)
Date: Fri, 21 Feb 2003 18:09:29 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.62-mm2
Message-Id: <20030221180929.37ba5f57.akpm@digeo.com>
In-Reply-To: <200302212048.09802.tomlins@cam.org>
References: <20030220234733.3d4c5e6d.akpm@digeo.com>
	<200302212048.09802.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> On February 21, 2003 02:47 am, Andrew Morton wrote:
> > So this tree has three elevators (apart from the no-op elevator).  You can
> > select between them via the kernel boot commandline:
> >
> >         elevator=as
> >         elevator=cfq
> >         elevator=deadline
> 
> Has anyone been having problems booting with 'as'?  It hangs here at the point
> root gets mounted readonly.  cfq works ok.

Might be another jiffy handling problem.  Would be appreciated if you could
retest with a patch -R of

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.62/2.5.62-mm2/broken-out/initial-jiffies.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
