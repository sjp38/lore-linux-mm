Date: Mon, 9 Feb 2004 02:24:53 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.3-rc1-mm1
Message-Id: <20040209022453.44e7f453.akpm@osdl.org>
In-Reply-To: <1076320225.671.7.camel@chevrolet.hybel>
References: <20040209014035.251b26d1.akpm@osdl.org>
	<1076320225.671.7.camel@chevrolet.hybel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stian Jordet <liste@jordet.nu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stian Jordet <liste@jordet.nu> wrote:
>
> man, 09.02.2004 kl. 10.40 skrev Andrew Morton:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc1/2.6.3-rc1-mm1/
> 
> Pretty, pretty please take Karstein Keil's big isdn update from
> 
> ftp://ftp.isdn4linux.de/pub/isdn4linux/kernel/v2.6
> 

Boggle.  That thing is 1.8MB.

 163 files changed, 25877 insertions(+), 22424 deletions(-)

This is the first time that anyone told me that it even existed.  How on
earth could a patch to a major subsystem grow to such a size in such
isolation?  When we're at kernel version 2.6.3!

How mature is this code?  What is its testing status?  What is the size of
its user base?  Is it available as individual, changelogged patches?

It would be crazy to simply shut our eyes and slam something of this
magnitude into the tree.  And it is totally unreasonable to expect
interested parties to be able to review and understand it.

Could someone please tell me how this situation came about, and what we can
do to prevent any reoccurrence?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
