Date: Mon, 16 Feb 2004 10:52:46 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-ID: <32440000.1076957566@flay>
In-Reply-To: <20040216104436.7e529efd.akpm@osdl.org>
References: <4030BB86.8060206@cyberone.com.au><7090000.1076946440@[10.10.2.4]><20040216095746.5ad2656b.akpm@osdl.org><30430000.1076956618@flay> <20040216104436.7e529efd.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: piggin@cyberone.com.au, Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It would need a lot of compile-testing.

Indeed. But it seems like the Right Thing to Do (tm). I have a fair
collection of config files, and a fast compile box ;-)

> atomic_t, list_head, pte_chain, pte_addr_t all need to be in scope and
> address_space needs a forward decl.  I bet other stuff will explode.

OK, I shall try it, and if I never speak again on the subject, I am
whimpering like a yellow coward in a dark corner somewhere from the
resultant fallout ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
