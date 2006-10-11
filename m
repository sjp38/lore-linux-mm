Subject: Re: Removing MAX_ARG_PAGES (request for comments/assistance)
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com>
References: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 11 Oct 2006 10:00:21 +0200
Message-Id: <1160553621.3000.355.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@muc.de>, linux-arch@vger.kernel.org, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 17:05 -0700, Ollie Wild wrote:

on first sight it looks like you pin the entire userspace buffer at the
same time (but I can misread the code; this stuff is a bit of a
spaghetti by nature); that would be a DoS scenario if true...


 -- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
