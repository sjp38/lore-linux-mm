Date: Mon, 16 Feb 2004 18:31:43 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-Id: <20040216183143.512c3d5e.akpm@osdl.org>
In-Reply-To: <20040216190927.GA2969@us.ibm.com>
References: <20040216190927.GA2969@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Paul E. McKenney" <paulmck@us.ibm.com> wrote:
>
>  The attached patch to make invalidate_mmap_range() non-GPL exported
>  seems to have been lost somewhere between 2.6.1-mm4 and 2.6.1-mm5.
>  It still applies cleanly.  Could you please take it up again?

I don't have any particular opinions either way but I do recall there was
some disquiet last time this came up.  I'm sure someone will remind us ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
