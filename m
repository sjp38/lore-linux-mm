Date: Mon, 25 Feb 2002 18:01:22 -0800 (PST)
Message-Id: <20020225.180122.120462472.davem@redhat.com>
Subject: Re: [PATCH] struct page shrinkage
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.33L.0202252254380.7820-100000@imladris.surriel.com>
References: <20020225.174911.82037594.davem@redhat.com>
	<Pine.LNX.4.33L.0202252254380.7820-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: marcelo@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   On Mon, 25 Feb 2002, David S. Miller wrote:
   
   > Please fix the atomic_t assumptions in init_page_count() first.
   > You should be using atomic_set(...).
   
   Why ?   You'll see init_page_count() is _only_ used from
   free_area_init_core(), when nothing else is using the VM
   yet.
   
Rik, not every architecture has a "counter" member of
atomic_t, that is the problem.  This is a hard bug, please
fix it.  It is an opaque type, accessing its' implementation
directly is therefore illegal in the strongest way possible.

   This exact same code has been in -rmap for a few months
   and went into 2.5 just over a week ago.  It doesn't seem
   to give any problems ...

Because I haven't pushed my sparc64 changesets yet, I'm doing
that tonight.

Franks a lot,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
