Date: Sat, 12 Nov 2005 23:12:11 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-Id: <20051112231211.372be3a9.akpm@osdl.org>
In-Reply-To: <20051112211429.294b3783.pj@sgi.com>
References: <20051107174349.A8018@unix-os.sc.intel.com>
	<20051107175358.62c484a3.akpm@osdl.org>
	<1131416195.20471.31.camel@akash.sc.intel.com>
	<43701FC6.5050104@yahoo.com.au>
	<20051107214420.6d0f6ec4.pj@sgi.com>
	<43703EFB.1010103@yahoo.com.au>
	<1131473876.2400.9.camel@akash.sc.intel.com>
	<43716476.1030306@yahoo.com.au>
	<20051112210913.0b365815.pj@sgi.com>
	<20051112211429.294b3783.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: nickpiggin@yahoo.com.au, rohit.seth@intel.com, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> wrote:
>
>  fs/xfs/linux-2.6/xfs_buf.c has:
>      aentry = kmalloc(sizeof(a_list_t), GFP_ATOMIC & ~__GFP_HIGH);

That's a reasonable thing to do, actually.

GFP_ATOMIC means "don't sleep" (!__GFP_WAIT) and "use emergency pools"
(__GFP_HIGH).

XFS is saying "don't sleep" and "don't use the emergency pools".

Yes, the fact that GFP_ATOMIC also implies "use the emergency pool" is
unfortunate, and perhaps the two should always have been separated out, at
least to make the programmer think about whether the code really needs
access to the emergency pools.   Usually it does.

But I haven't seen much sign that it's causing any problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
