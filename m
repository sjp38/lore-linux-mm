Date: Fri, 10 Oct 2003 01:50:18 -0700
From: "David S. Miller" <davem@redhat.com>
Subject: Re: TLB flush optimization on s/390.
Message-Id: <20031010015018.7afb5ca0.davem@redhat.com>
In-Reply-To: <OFF67143AC.941FD14C-ONC1256DBB.002D6C6B-C1256DBB.002DCC69@de.ibm.com>
References: <OFF67143AC.941FD14C-ONC1256DBB.002D6C6B-C1256DBB.002DCC69@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: akpm@osdl.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, willy@debian.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Oct 2003 10:20:14 +0200
"Martin Schwidefsky" <schwidefsky@de.ibm.com> wrote:

> Would you care to explain why this is a problem? It's a static function
> that gets folded into another static function. I added additional arguments
> to copy_one_pte and to avoid to make move_one_page slower I though to
> inline it would be a good idea.

On at least x86 and sparc it makes it so that GCC cannot allocate
enough registers and it has to reload several values to the
stack.

In general when the functions are huge it never makes sense to
inline them even if only used in one place.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
