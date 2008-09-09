Date: Mon, 8 Sep 2008 17:56:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Cleanup to make  remove_memory() arch neutral
Message-Id: <20080908175621.6dfad0a6.akpm@linux-foundation.org>
In-Reply-To: <1220910754.25932.57.camel@badari-desktop>
References: <20080905172132.GA11692@us.ibm.com>
	<20080905174449.GC27395@elte.hu>
	<1220638478.25932.20.camel@badari-desktop>
	<20080905181754.GA14258@elte.hu>
	<1220910754.25932.57.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: garyhade@us.ibm.com, linux-mm@kvack.org, y-goto@jp.fujitsu.com, mel@csn.ul.ie, lcm@us.ibm.com, linux-kernel@vger.kernel.org, x86@kernel.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Mon, 08 Sep 2008 14:52:34 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> There is nothing architecture specific about remove_memory().
> remove_memory() function is common for all architectures which
> support hotplug memory remove. Instead of duplicating it in every
> architecture, collapse them into arch neutral function.
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> 
>  arch/ia64/mm/init.c   |   17 -----------------
>  arch/powerpc/mm/mem.c |   17 -----------------
>  arch/s390/mm/init.c   |   11 -----------
>  mm/memory_hotplug.c   |   10 ++++++++++
>  4 files changed, 10 insertions(+), 45 deletions(-)

I spent some time trying to build-test this on ia64 and gave up.  How
the heck do you turn on memory hotplug on ia64?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
