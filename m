Date: Fri, 27 Feb 2004 18:11:53 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: mapped page in prep_new_page()..
Message-ID: <20040227071153.GA5801@krispykreme>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org> <20040226225809.669d275a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040226225809.669d275a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, hch@infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> There have been a few.  I don't recall seeing any against x86.

There was a G5 user that was seeing oopses in buffered_rmqueue (I notice
thats in the backtrace), it turned out to be bad RAM.

> So what is the access address here?  That will tell us what value was in
> page.pte.chain.

We tried to access 0x5f00000008. Doesnt look like much to me.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
