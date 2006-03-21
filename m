Subject: Re: [PATCH][5/8] proc: export mlocked pages info through
	"/proc/meminfo: Wired"
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <bc56f2f0603210733vc3ce132p@mail.gmail.com>
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>
	 <441FEFC7.5030109@yahoo.com.au> <bc56f2f0603210733vc3ce132p@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 21 Mar 2006 20:43:00 +0100
Message-Id: <1142970181.3077.103.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-03-21 at 10:33 -0500, Stone Wang wrote:
> The list potentially could have more wider use.
> 
> For example, kernel-space locked/pinned pages could be placed on the list too
> (while mlocked pages are locked/pinned by system calls from user-space).

then please call it pinned_list or locked_down_list or so ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
