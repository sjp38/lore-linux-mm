Message-ID: <478A6E36.1030309@cosmosbay.com>
Date: Sun, 13 Jan 2008 21:01:58 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] x86: Change size of node ids from u8 to u16
References: <20080113183453.973425000@sgi.com> <20080113183454.288993000@sgi.com>
In-Reply-To: <20080113183454.288993000@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

travis@sgi.com a ecrit :
> Change the size of node ids from 8 bits to 16 bits to
> accomodate more than 256 nodes.
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Reviewed-by: Christoph Lameter <clameter@sgi.com>
> ---
>  arch/x86/mm/numa_64.c      |    9 ++++++---
>  arch/x86/mm/srat_64.c      |    2 +-
>  include/asm-x86/numa_64.h  |    4 ++--
>  include/asm-x86/topology.h |    2 +-
>  4 files changed, 10 insertions(+), 7 deletions(-)

So, you think some machine is going to have more than 256 nodes ?

If so, you probably need to change 'struct memnode' too 
(include/asm-x86/mmzone_64.h)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
