Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 406CA6B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:12:25 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 22so981235fge.8
        for <linux-mm@kvack.org>; Wed, 20 Jan 2010 15:12:23 -0800 (PST)
Message-ID: <4B578DD4.90908@suse.cz>
Date: Thu, 21 Jan 2010 00:12:20 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] bootmem: avoid DMA32 zone by default
References: <20100120153000.GA13172@cmpxchg.org> <1264027998-15257-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1264027998-15257-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, x86@kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On 01/20/2010 11:53 PM, Johannes Weiner wrote:
> I cc'd stable because this affects already released kernels.  But since this is
> the first report of DMA32 memory exhaustion through bootmem that I hear of,

Just for how the setup look like:
128G of RAM, flat mapping
sizeof(struct page)=56
0-1.75G mem_map
1.75-2G vfs caches, console and others. initrd reservation
2-4G reserved by BIOS

Kernel panics with out of memory when swiotlb tries to allocate 64M of
"low" bootmem.

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
