Subject: Re: follow_page()
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <41935AB9.7000101@yahoo.com.au>
References: <20041111024015.7c50c13d.akpm@osdl.org>
	 <1100170570.2646.27.camel@laptop.fenrus.org>
	 <20041111030634.1d06a7c1.akpm@osdl.org>
	 <1100171453.2646.29.camel@laptop.fenrus.org>
	 <419353D5.2080902@yahoo.com.au> <1100175387.4387.1.camel@laptop.fenrus.org>
	 <41935AB9.7000101@yahoo.com.au>
Content-Type: text/plain
Message-Id: <1100177165.4387.4.camel@laptop.fenrus.org>
Mime-Version: 1.0
Date: Thu, 11 Nov 2004 13:46:06 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Well, if you write into the page returned via follow_page, that
> isn't going to dirty the pte by itself... so it is a bit of a
> hit and miss regarding whether the page really will get dirtied
> through that pte in the near future (I don't know, maybe that
> is generally what happens with normal usage patterns?).

that's why the function has a parameter saying it is for writing too, I
think...

either way this deserves some comments in the code...
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
