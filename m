Date: Wed, 23 Jan 2002 11:06:24 -0800 (PST)
Message-Id: <20020123.110624.93021436.davem@redhat.com>
Subject: Re: [PATCH *] rmap VM, version 12
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.33L.0201231650450.32617-100000@imladris.surriel.com>
References: <20020123.104438.71552152.davem@redhat.com>
	<Pine.LNX.4.33L.0201231650450.32617-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   On Wed, 23 Jan 2002, David S. Miller wrote:
   
   > The problem is that when vmalloc() or whatever kernel mappings change
   > you have to update all the quicklist page tables to match.
   
   Actually, this is just using the pte_free_fast() and
   {get,free}_pgd_fast() functions on non-pae machines.
   
Rofl, you can't just do that.  The page tables cache caches the kernel
mappings and if you don't update them properly on SMP you die.

I am seeing reports of SMP failing with rmap12 but not previous
patches.  You need to revert this I think.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
