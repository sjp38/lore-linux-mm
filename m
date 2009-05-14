Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B55986B01BC
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:56:56 -0400 (EDT)
Date: Thu, 14 May 2009 09:57:47 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to
	64 bits in X86_64
Message-ID: <20090514135747.GA7926@infradead.org>
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1242202647-32446-1-git-send-email-sheng@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Sheng Yang <sheng@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 04:17:27PM +0800, Sheng Yang wrote:
> This fix 44/45 bit width memory can't boot up issue. The reason is
> free_bootmem_node()->mark_bootmem_node()->__free() use test_and_clean_bit() to
> clean node_bootmem_map, but for 44bits width address, the idx set bit 31 (43 -
> 12), which consider as a nagetive value for bts.

Should we really have different prototypes for these helpers on
different architectures?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
