Date: Wed, 23 Jan 2002 10:44:38 -0800 (PST)
Message-Id: <20020123.104438.71552152.davem@redhat.com>
Subject: Re: [PATCH *] rmap VM, version 12
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.33L.0201231513571.32617-100000@imladris.surriel.com>
References: <Pine.LNX.4.33L.0201231513571.32617-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

     - use fast pte quicklists on non-pae machines           (Andrea Arcangeli)

Does this work on SMP?  I remember they were turned off because
they were simply broken on SMP.

The problem is that when vmalloc() or whatever kernel mappings change
you have to update all the quicklist page tables to match.

Andrea probably fixed this, I haven't looked at the patch.
If so, ignoreme.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
