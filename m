Subject: Re: TLB flush optimization on s/390.
Message-ID: <OF6AFB1404.2D92608A-ONC1256DBB.002F0E43-C1256DBB.002F5F7D@de.ibm.com>
From: "Martin Schwidefsky" <schwidefsky@de.ibm.com>
Date: Fri, 10 Oct 2003 10:37:26 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: akpm@osdl.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, willy@debian.org
List-ID: <linux-mm.kvack.org>

> On at least x86 and sparc it makes it so that GCC cannot allocate
> enough registers and it has to reload several values to the
> stack.

And the function call overhead is smaller then the register spilling
on the stack ?!? I'm a bit surprised by this but I take you word
for it.

blue skies,
   Martin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
