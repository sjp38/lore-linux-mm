Date: Wed, 23 Jan 2002 12:18:57 -0800 (PST)
Message-Id: <20020123.121857.18310310.davem@redhat.com>
Subject: Re: [PATCH *] rmap VM, version 12
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.33L.0201231735540.32617-100000@imladris.surriel.com>
References: <20020123.112837.112624842.davem@redhat.com>
	<Pine.LNX.4.33L.0201231735540.32617-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   
   OK, so only the _pgd_ quicklist is questionable and the
   _pte_ quicklist is fine ?

That is my understanding.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
