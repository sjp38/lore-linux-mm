Subject: Re: 2.5.62-mm2
From: Shawn <core@enodev.com>
In-Reply-To: <200302212048.09802.tomlins@cam.org>
References: <20030220234733.3d4c5e6d.akpm@digeo.com>
	 <200302212048.09802.tomlins@cam.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1045881657.27435.36.camel@localhost.localdomain>
Mime-Version: 1.0
Date: 21 Feb 2003 20:40:58 -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@digeo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For some reason, I had to boot single, then go to multi user.

Otherwise, I got some sort  of interrupt not free messages after my
second ide ctrlr got recognized.

On Fri, 2003-02-21 at 19:48, Ed Tomlinson wrote:
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
> 
> 
> 
> If this has already been reported sorry - mail is lagging here.
> 
> Ed Tomlinson
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
