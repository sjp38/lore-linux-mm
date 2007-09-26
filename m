Subject: Re: [RFC] [PATCH] memory controller statistics
In-Reply-To: Your message of "Fri, 07 Sep 2007 10:55:44 +0100"
	<46E12020.1060203@linux.vnet.ibm.com>
References: <46E12020.1060203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070926014843.161E61BFA33@siro.lan>
Date: Wed, 26 Sep 2007 10:48:42 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.osdl.org, minoura@valinux.co.jp, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> YAMAMOTO Takashi wrote:
> > hi,
> > 
> > i implemented some statistics for your memory controller.
> > 
> > it's tested with 2.6.23-rc2-mm2 + memory controller v7.
> > i think it can be applied to 2.6.23-rc4-mm1 as well.
> > 
> 
> Thanks for doing this. We are building containerstats for
> per container statistics. It would be really nice to provide
> the statistics using that interface. I am not opposed to
> memory.stat, but Paul Menage recommends that one file has
> just one meaningful value.
> 
> The other thing is that could you please report all the
> statistics in bytes, we are moving to that interface,
> I've posted patches to do that. If we are going to push
> a bunch of statistics in one file, please use a format
> separator like
> 
> name: value

i followed /proc/vmstat.
are you going to convert /proc/vmstat to the format as well?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
