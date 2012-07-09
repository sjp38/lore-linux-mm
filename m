Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 28C8E6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 18:41:02 -0400 (EDT)
Date: Mon, 9 Jul 2012 15:41:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when
 order 0
Message-Id: <20120709154100.6a7377e6.akpm@linux-foundation.org>
In-Reply-To: <CAAmzW4P=Qf1u6spPZCN7o3TRqvwF-rZkZA3eFtAcnCdFg2CDBg@mail.gmail.com>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com>
	<CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
	<alpine.DEB.2.00.1207081547140.18461@chino.kir.corp.google.com>
	<CAAmzW4P=Qf1u6spPZCN7o3TRqvwF-rZkZA3eFtAcnCdFg2CDBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jul 2012 23:13:50 +0900
JoonSoo Kim <js1304@gmail.com> wrote:

> >> In my kernel image, __alloc_pages_direct_compact() is not inlined by gcc.

My gcc-4.4.4 doesn't inline it either.

> I think __alloc_pages_direct_compact() can't be inlined by gcc,
> because it is so big and is invoked two times in __alloc_pages_nodemask().

This.  Large function, two callsites.

Making __alloc_pages_direct_compact() __always_inline adds only 26
bytes to my page_alloc.o's .text.  Such is the suckiness of passing
eleven arguments!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
