Date: Thu, 26 Feb 2004 23:21:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mapped page in prep_new_page()..
Message-Id: <20040226232127.27cefb26.akpm@osdl.org>
In-Reply-To: <20040227071153.GA5801@krispykreme>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
	<20040226225809.669d275a.akpm@osdl.org>
	<20040227071153.GA5801@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: torvalds@osdl.org, hch@infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anton Blanchard <anton@samba.org> wrote:
>
> > So what is the access address here?  That will tell us what value was in
> > page.pte.chain.
> 
> We tried to access 0x5f00000008. Doesnt look like much to me.
> 

So on a G5 that is neither a valid kernel pointer nor a valid pte_addr_t?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
