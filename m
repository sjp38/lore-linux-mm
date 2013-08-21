Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 2B0626B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 01:31:47 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ev20so1005868lab.39
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 22:31:45 -0700 (PDT)
Date: Wed, 21 Aug 2013 09:31:42 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 0/3] mm: shmem: check the return value of mpol_to_str()
Message-ID: <20130821053142.GQ18673@moon>
References: <5212E8DF.5020209@asianux.com>
 <20130820053036.GB18673@moon>
 <52130194.4030903@asianux.com>
 <20130820064730.GD18673@moon>
 <52131F48.1030002@asianux.com>
 <52132011.60501@asianux.com>
 <52132432.3050308@asianux.com>
 <20130820082516.GE18673@moon>
 <52142422.9050209@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52142422.9050209@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Aug 21, 2013 at 10:21:22AM +0800, Chen Gang wrote:
> mpol_to_str() may fail, and not fill the buffer (e.g. -EINVAL), so need
> check about it, or buffer may not be zero based, and next seq_printf()
> will cause issue.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>

Looks good to me, thanks!

Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
