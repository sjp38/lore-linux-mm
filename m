Date: Mon, 16 Feb 2004 09:57:46 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-Id: <20040216095746.5ad2656b.akpm@osdl.org>
In-Reply-To: <7090000.1076946440@[10.10.2.4]>
References: <4030BB86.8060206@cyberone.com.au>
	<7090000.1076946440@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: piggin@cyberone.com.au, Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> --Nick Piggin <piggin@cyberone.com.au> wrote (on Monday, February 16, 2004 23:45:58 +1100):
> 
> > Ok ok, I'll do it... is this the right way to go about it?
> > I'm assuming it is worth doing?
> 
> 
> What were the include dependencies you ran into originally? Were they 
> not fixable somehow? They probably need fixing anyway ;-)
> 

We would need struct page in scope for mmzone.h.  Not nice.  It could be
done: move the bare pageframe defn into its own header with appropriate
forward decls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
