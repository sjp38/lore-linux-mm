Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id CB1B86B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 22:28:43 -0400 (EDT)
Message-ID: <5179E652.808@zytor.com>
Date: Thu, 25 Apr 2013 19:28:34 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop> <517861E0.7030801@zytor.com> <51786D52.1080509@gmail.com>
In-Reply-To: <51786D52.1080509@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/24/2013 04:40 PM, Simon Jeons wrote:
> 
> I see in memblock_trim_memory(): start = round_up(orig_start, align);
> here align is PAGE_SIZE, so the dump of zone ranges in my machine is [ 
>   0.000000]  DMA      [mem 0x00001000-0x00ffffff]. Why PFN 0 is not
> used? just for align?
> 

PFN 0 contains the real-mode interrupt vector table and BIOS data area,
so we just reserve it.  Avoids issues with zero being special, too.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
