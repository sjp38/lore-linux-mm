Subject: Re: 2.6.3-rc1-mm1
From: Stian Jordet <liste@jordet.nu>
In-Reply-To: <20040209022453.44e7f453.akpm@osdl.org>
References: <20040209014035.251b26d1.akpm@osdl.org>
	 <1076320225.671.7.camel@chevrolet.hybel>
	 <20040209022453.44e7f453.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1076322566.671.10.camel@chevrolet.hybel>
Mime-Version: 1.0
Date: Mon, 09 Feb 2004 11:29:26 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

man, 09.02.2004 kl. 11.24 skrev Andrew Morton:
> Boggle.  That thing is 1.8MB.
> 
>  163 files changed, 25877 insertions(+), 22424 deletions(-)
> 
> This is the first time that anyone told me that it even existed.  How on
> earth could a patch to a major subsystem grow to such a size in such
> isolation?  When we're at kernel version 2.6.3!
> 
> How mature is this code?  What is its testing status?  What is the size of
> its user base?  Is it available as individual, changelogged patches?
> 
> It would be crazy to simply shut our eyes and slam something of this
> magnitude into the tree.  And it is totally unreasonable to expect
> interested parties to be able to review and understand it.
> 
> Could someone please tell me how this situation came about, and what we can
> do to prevent any reoccurrence?

I don't know more than this:

http://marc.theaimsgroup.com/?l=linux-kernel&m=107523583528989&w=2

But I _do_ know that ISDN is non-working for me with 2.6.x kernels
without this patch. 

Best regards,
Stian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
