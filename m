Date: Sat, 5 Jul 2003 14:17:40 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1
Message-ID: <20030705211740.GA15452@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <20030704210737.GI955@holomorphy.com> <20030704181539.2be0762a.akpm@osdl.org> <20030705104433.GK955@holomorphy.com> <20030705114308.6dacb5a2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030705114308.6dacb5a2.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 05, 2003 at 11:43:08AM -0700, Andrew Morton wrote:
> if badness() returns zero for everything, this returns NULL and
> the kernel panics.

Sorry, that was one hell of an oversight wrt. the initival value.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
