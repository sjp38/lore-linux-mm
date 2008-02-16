Message-ID: <47B6BDDF.90502@inria.fr>
Date: Sat, 16 Feb 2008 11:41:35 +0100
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [patch 1/6] mmu_notifier: Core code
References: <20080215064859.384203497@sgi.com>	<20080215064932.371510599@sgi.com> <20080215193719.262c03a1.akpm@linux-foundation.org>
In-Reply-To: <20080215193719.262c03a1.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> What is the status of getting infiniband to use this facility?
>
> How important is this feature to KVM?
>
> To xpmem?
>
> Which other potential clients have been identified and how important it it
> to those?
>   

As I said when Andrea posted the first patch series, I used something
very similar for non-RDMA-based HPC about 4 years ago. I haven't had
time yet to look in depth and try the latest proposed API but my feeling
is that it looks good.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
