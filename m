Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1509480000.1097591191@[10.10.2.4]>
References: <20041008100010.GB16028@logos.cnet>
	 <20041008.212319.19886370.taka@valinux.co.jp>
	 <20041008124149.GI16028@logos.cnet>
	 <20041009.015239.74741436.taka@valinux.co.jp>
	 <20041008153646.GJ16028@logos.cnet>
	 <20041012105657.D1D0670463@sv1.valinux.co.jp>
	 <1509480000.1097591191@[10.10.2.4]>
Content-Type: text/plain
Message-Id: <1097593292.8085.1776.camel@localhost>
Mime-Version: 1.0
Date: Tue, 12 Oct 2004 08:01:32 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-12 at 07:26, Martin J. Bligh wrote:
> Lots of systems nowadays don't have swap configured, not just embedded.
> What do we gain from making defrag slower and harder to use, by forcing
> it to use swap? Isn't pushing it into the swapcache sufficient?

For now, with no swap space configured and CONFIG_SWAP=y, no pages will
even make it into the swap cache.  It'll take more code on top of what
we have to get that to work.  So, we're sticking with the smallest
amount of code that we can for now.  We'll fix that up later.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
