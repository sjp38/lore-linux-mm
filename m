From: Karl Vogel <karl.vogel@seagha.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Date: Tue, 31 Aug 2004 21:36:38 +0200
References: <20040829141718.GD10955@suse.de> <200408312024.32158.karl.vogel@seagha.com> <20040831172531.GA18184@logos.cnet>
In-Reply-To: <20040831172531.GA18184@logos.cnet>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200408312136.39192.karl.vogel@seagha.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 31 August 2004 19:25, Marcelo Tosatti wrote:
> Can you try the same tests with 2.6.8.1 and check the difference, pretty
> please?

You forgot the sugar on top :)  Anyway 2.6.8.1 also seems to behave now.. I do 
get a few 'kswapd0: page allocation failure. order:0, mode:0x20' but the 
system doesn't OOM kill and it recovers after the expunge. Although I think 
it recovers a tad slower than 2.6.9-rc1-bk3

 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
