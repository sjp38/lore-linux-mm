Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9DBBC6B0037
	for <linux-mm@kvack.org>; Fri, 17 May 2013 12:04:38 -0400 (EDT)
Date: Fri, 17 May 2013 17:04:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv11 4/4] zswap: add documentation
Message-ID: <20130517160431.GO11497@suse.de>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-5-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1368448803-2089-5-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 13, 2013 at 07:40:03AM -0500, Seth Jennings wrote:
> This patch adds the documentation file for the zswap functionality
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  Documentation/vm/zswap.txt |   72 ++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 72 insertions(+)
>  create mode 100644 Documentation/vm/zswap.txt
> 
> diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
> new file mode 100644
> index 0000000..88384b3
> --- /dev/null
> +++ b/Documentation/vm/zswap.txt
> @@ -0,0 +1,72 @@
> +Overview:
> +
> +Zswap is a lightweight compressed cache for swap pages. It takes pages that are
> +in the process of being swapped out and attempts to compress them into a
> +dynamically allocated RAM-based memory pool.  If this process is successful,
> +the writeback to the swap device is deferred and, in many cases, avoided
> +completely.  This results in a significant I/O reduction and performance gains
> +for systems that are swapping.
> +

*Potentially* reduces IO and *potentially* shows performance gains. If the
system is swap trashing, this may make things worse as you're generating
the same amount of IO but having to compress/decompress as well. If there
is less physical memory available because zswap pool is fragmented then an
application may be pushed to swap prematurely and again, the performance
is worse. Don't oversell this and the comment applies throughout the
documentation.

I also think it should be marked with a bit fat warning that it's a WIP
and an additional warning that the performance characteristics are very
heavily workload dependant.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
