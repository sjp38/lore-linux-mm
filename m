Date: Mon, 16 Feb 2004 09:54:11 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.3-rc3-mm1
Message-Id: <20040216095411.1592d09d.akpm@osdl.org>
In-Reply-To: <4030B48F.2070603@tmr.com>
References: <20040216015823.2dafabb4.akpm@osdl.org>
	<4030B48F.2070603@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bill Davidsen <davidsen@tmr.com> wrote:
>
> > - Dropped the x86 CPU-type selection patches
> 
>  Was there a problem with this? Seems like a good start to allow cleaning 
>  up some "but I don't have that CPU" things which embedded and tiny 
>  systems really would like to eliminate.

I think it was a good change, and was appropriate to 2.5.x.  But for 2.6.x
the benefit didn't seem to justify the depth of the change.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
