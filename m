Date: Sat, 28 Jun 2003 16:00:13 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.73-mm2
Message-Id: <20030628160013.46a5b537.akpm@digeo.com>
In-Reply-To: <20030628155436.GY20413@holomorphy.com>
References: <20030627202130.066c183b.akpm@digeo.com>
	<20030628155436.GY20413@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
>  Here's highpmd.

I taught patch-scripts a new trick:

check_patch()
{
	if grep "^+.*[ 	]$" $P/patches/$1.patch
	then
		echo warning: $1 adds trailing whitespace
	fi
}


+       if (pmd_table != pmd_offset_kernel(pgd, 0)) 
+       pmd = pmd_offset_kernel(pgd, address);         
+#define __pgd_page(pgd)                (__bpn_to_ba(pgd_val(pgd))) 
warning: highpmd adds trailing whitespace

You're far from the worst.   There's some editor out there which
adds trailing tabs all over the place.  I edited the diff.

What architectures has this been tested on?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
