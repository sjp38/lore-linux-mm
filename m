Date: Mon, 25 Feb 2002 17:49:11 -0800 (PST)
Message-Id: <20020225.174911.82037594.davem@redhat.com>
Subject: Re: [PATCH] struct page shrinkage
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.33L.0202252245460.7820-100000@imladris.surriel.com>
References: <Pine.LNX.4.33L.0202252245460.7820-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: marcelo@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   Please apply for 2.4.19-pre2.

Please fix the atomic_t assumptions in init_page_count() first.
You should be using atomic_set(...).

Franks a lot,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
