Subject: Re: 2.6.3-rc2-mm1
From: Mark Haverkamp <markh@osdl.org>
In-Reply-To: <402B6251.2060909@cyberone.com.au>
References: <20040212015710.3b0dee67.akpm@osdl.org>
	 <402B6251.2060909@cyberone.com.au>
Content-Type: text/plain
Message-Id: <1076600437.22976.3.camel@markh1.pdx.osdl.net>
Mime-Version: 1.0
Date: Thu, 12 Feb 2004 07:40:38 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christine Moore <cem@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-02-12 at 03:24, Nick Piggin wrote:
> Andrew Morton wrote:
> 
> >ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc2/2.6.3-rc2-mm1/
> >
> >
> 
> Nether this nor the previous one boots on the NUMAQ at osdl.
> Not sure which is the last -mm that did. 2.6.3-rc2 boots.
> 
> I turned early_printk on and nothing. It stops at
> Loading linux..............

I saw this behavior with the last mm kernel on my 8-way with
CONFIG_HIGHMEM64G.  The problem went away when I backed out the
highmem-equals-user-friendliness.patch

Mark.

-- 
Mark Haverkamp <markh@osdl.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
