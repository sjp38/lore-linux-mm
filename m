Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C43AF6B0037
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 04:25:20 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id es20so84129lab.10
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 01:25:18 -0700 (PDT)
Date: Tue, 20 Aug 2013 12:25:16 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 0/3] mm: mempolicy: the failure processing about
 mpol_to_str()
Message-ID: <20130820082516.GE18673@moon>
References: <5212E8DF.5020209@asianux.com>
 <20130820053036.GB18673@moon>
 <52130194.4030903@asianux.com>
 <20130820064730.GD18673@moon>
 <52131F48.1030002@asianux.com>
 <52132011.60501@asianux.com>
 <52132432.3050308@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52132432.3050308@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 20, 2013 at 04:09:22PM +0800, Chen Gang wrote:
> So, for simplify thinking and implementation, use your patch below is OK
> to me (but I suggest to print error information in the none return value
> function).

Chen, I'm not going to dive into this area now, too busy with other stuff
sorry, so if you consider my preliminary draft patch useful -- pick it up,
modify it, test it and send to lkml then (just CC me).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
