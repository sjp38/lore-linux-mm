Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D0A386B01CF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:32:29 -0400 (EDT)
Message-ID: <4A0C2AC6.3000207@zytor.com>
Date: Thu, 14 May 2009 07:29:26 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to
 64 bits in X86_64
References: <1242202647-32446-1-git-send-email-sheng@linux.intel.com> <20090514135747.GA7926@infradead.org>
In-Reply-To: <20090514135747.GA7926@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Sheng Yang <sheng@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Wed, May 13, 2009 at 04:17:27PM +0800, Sheng Yang wrote:
>> This fix 44/45 bit width memory can't boot up issue. The reason is
>> free_bootmem_node()->mark_bootmem_node()->__free() use test_and_clean_bit() to
>> clean node_bootmem_map, but for 44bits width address, the idx set bit 31 (43 -
>> 12), which consider as a nagetive value for bts.
> 
> Should we really have different prototypes for these helpers on
> different architectures?
> 

We already do: SPARC and MIPS have unsigned long, and apparently have
been unsigned long for a long time.  Given how the x86 bitops work, they
would have to be signed, which would mean to introduce a third
prototype, which really is the suck, but it's not like it would be the
only oddball.  Either that or we have to redesign the bootmem system for
very large amounts of memory.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
