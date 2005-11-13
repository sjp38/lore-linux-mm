Date: Sun, 13 Nov 2005 18:00:39 +1100
From: Nathan Scott <nathans@sgi.com>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-ID: <20051113180039.A6583673@wobbly.melbourne.sgi.com>
References: <20051107174349.A8018@unix-os.sc.intel.com> <20051107175358.62c484a3.akpm@osdl.org> <1131416195.20471.31.camel@akash.sc.intel.com> <43701FC6.5050104@yahoo.com.au> <20051107214420.6d0f6ec4.pj@sgi.com> <43703EFB.1010103@yahoo.com.au> <1131473876.2400.9.camel@akash.sc.intel.com> <43716476.1030306@yahoo.com.au> <20051112210913.0b365815.pj@sgi.com> <20051112211429.294b3783.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051112211429.294b3783.pj@sgi.com>; from pj@sgi.com on Sat, Nov 12, 2005 at 09:14:29PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: nickpiggin@yahoo.com.au, rohit.seth@intel.com, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 12, 2005 at 09:14:29PM -0800, Paul Jackson wrote:
> An even stranger line:
> 
> fs/xfs/linux-2.6/xfs_buf.c has:
>     aentry = kmalloc(sizeof(a_list_t), GFP_ATOMIC & ~__GFP_HIGH);
> 
> Given the gfp.h line:
>     #define GFP_ATOMIC  (__GFP_VALID | __GFP_HIGH)
> 
> that xfs_buf line makes no sense.  There is almost no chance
> that the author of that xfs_buf.c line was aware they were
> spelling the empty gfp flag __GFP_VALID.

Actually, there is a very good chance of that - it was
Andrew's recommendation a few months back... ;)

cheers.

-- 
Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
