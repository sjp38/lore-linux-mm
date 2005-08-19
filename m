Date: Fri, 19 Aug 2005 06:34:35 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Concept for delayed counter updates in mm_struct
Message-ID: <20050819043435.GD3953@verdi.suse.de>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org> <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com> <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com> <20050818212939.7dca44c3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050818212939.7dca44c3.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, hugh@veritas.com, torvalds@osdl.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Is ptrace->get_user_pages() the only place where one process pokes
> at another process's memory?  I think so..

/proc/*/{cmdline,env}. But they all use get_user_pages()

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
