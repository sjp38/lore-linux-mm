Date: Thu, 7 Aug 2003 14:28:07 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test2-mm5
Message-Id: <20030807142807.3e4a284c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0308071819380.4791-100000@logos.cnet>
References: <20030806223716.26af3255.akpm@osdl.org>
	<Pine.LNX.4.44.0308071819380.4791-100000@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> wrote:
>
> PCI: Using configuration type 1
> 
> 
>  Locked up solid there. Want more info ? 

doh.  I don't even know who to lart for that one!

Could you please boot with "initcall_debug" and then resolve the final
couple of addresses in System.map?  That'll narrow it down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
