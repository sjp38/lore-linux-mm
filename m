Date: Tue, 19 Oct 2004 01:57:33 +0900 (JST)
Message-Id: <20041019.015733.71086634.taka@valinux.co.jp>
Subject: Re: [PATCH] Migration cache
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041014192240.GA6899@logos.cnet>
References: <20041014192240.GA6899@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: haveblue@us.ibm.com, iwamoto@valinux.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Marcelo,

Give me few days to check it.

> Hi MM fellows,
> 
> So as I've said before in my opinion moving pages to the swapcache 
> to migrate them is unnacceptable for several reasons. Not to mention 
> live memory defragmentation.
> 
> So the following patch, on top of the v2.6 -memoryhotplug tree, 
> creates a migration cache - which is basically a swapcache without 
> using the swap map - it instead uses a on-memory idr structure.

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
