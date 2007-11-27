Date: Tue, 27 Nov 2007 23:16:28 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/1] mm: Prevent dereferencing non-allocated per_cpu variables
Message-ID: <20071127221628.GG24223@one.firstfloor.org>
References: <20071127215052.090968000@sgi.com> <20071127215054.660250000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071127215054.660250000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, pageexec@freemail.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 27, 2007 at 01:50:53PM -0800, travis@sgi.com wrote:
> Change loops controlled by 'for (i = 0; i < NR_CPUS; i++)' to use
> 'for_each_possible_cpu(i)' when there's a _remote possibility_ of
> dereferencing a non-allocated per_cpu variable involved.
> 
> All files except mm/vmstat.c are x86 arch.
> 
> Based on 2.6.24-rc3-mm1 .
> 
> Thanks to pageexec@freemail.hu for pointing this out.

Looks good to me. 2.6.24 candidate.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
