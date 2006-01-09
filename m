Date: Mon, 9 Jan 2006 13:26:22 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] use local_t for page statistics
Message-ID: <20060109182622.GC16451@kvack.org>
References: <20060106215332.GH8979@kvack.org> <20060106163313.38c08e37.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060106163313.38c08e37.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 06, 2006 at 04:33:13PM -0800, Andrew Morton wrote:
> Bah.  I think this is a better approach than the just-merged
> mm-page_state-opt.patch, so I should revert that patch first?

After going over things, I think that I'll redo my patch on top of that 
one, as it means that architectures that can optimize away the save/restore 
of irq flags will be able to benefit from that.  Maybe after all this is 
said and done we can clean things up sufficiently to be able to inline the 
inc/dec where it is simple enough to do so.

		-ben
-- 
"You know, I've seen some crystals do some pretty trippy shit, man."
Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
