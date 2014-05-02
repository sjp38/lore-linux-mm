From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2 1/4] mm, migration: add destination page freeing
 callback
Date: Fri, 2 May 2014 11:10:28 +0100
Message-ID: <20140502101028.GO23991@suse.de>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Thu, May 01, 2014 at 02:35:37PM -0700, David Rientjes wrote:
> Memory migration uses a callback defined by the caller to determine how to
> allocate destination pages.  When migration fails for a source page, however, it 
> frees the destination page back to the system.
> 
> This patch adds a memory migration callback defined by the caller to determine 
> how to free destination pages.  If a caller, such as memory compaction, builds 
> its own freelist for migration targets, this can reuse already freed memory 
> instead of scanning additional memory.
> 
> If the caller provides a function to handle freeing of destination pages, it is 
> called when page migration fails.  Otherwise, it may pass NULL and freeing back 
> to the system will be handled as usual.  This patch introduces no functional 
> change.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs
