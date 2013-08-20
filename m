Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id F04026B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:00:27 -0400 (EDT)
Date: Tue, 20 Aug 2013 11:00:26 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/4] mm/pgtable: Fix continue to preallocate pmds even
 if failure occurrence
Message-ID: <20130820160026.GB4151@medulla.variantweb.net>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 20, 2013 at 02:54:53PM +0800, Wanpeng Li wrote:
> v1 -> v2:
>  * remove failed.
> 
> preallocate_pmds will continue to preallocate pmds even if failure
> occurrence, and then free all the preallocate pmds if there is
> failure, this patch fix it by stop preallocate if failure occurrence
> and go to free path.
> 

Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

> Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
