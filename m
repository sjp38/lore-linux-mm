Date: Mon, 19 Jan 2004 21:13:26 -0500 (EST)
From: Thomas Molina <tmolina@cablespeed.com>
Subject: Re: 2.6.1-mm4
In-Reply-To: <20040119165730.7f250869.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0401192107550.5662@localhost.localdomain>
References: <20040115225948.6b994a48.akpm@osdl.org>
 <Pine.LNX.4.58.0401191912300.5662@localhost.localdomain>
 <20040119165730.7f250869.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 19 Jan 2004, Andrew Morton wrote:

> > Cannot open master raw device '/dev/rawctl' (No such device)
> 
> Do you have
> 
> 	alias char-major-162 raw
> 
> in /etc/modprobe.conf?

I added that and got the same message on the next reboot.  I don't get 
this on the 2.4 RedHat kernel.  I will have to do a bk pull for 2.6 since 
I have been running mm kernels exclusively lately.  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
