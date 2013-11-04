Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id BF7AB6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 17:01:08 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fb1so7519828pad.37
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 14:01:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id tu7si9759174pab.162.2013.11.04.14.01.07
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 14:01:07 -0800 (PST)
Date: Mon, 4 Nov 2013 14:01:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add strictlimit knob
Message-Id: <20131104140104.7936d263258a7a6753eb325e@linux-foundation.org>
In-Reply-To: <20131101142941.1161.40314.stgit@dhcp-10-30-17-2.sw.ru>
References: <20131031142612.GA28003@kipc2.localdomain>
	<20131101142941.1161.40314.stgit@dhcp-10-30-17-2.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: karl.kiniger@med.ge.com, jack@suse.cz, linux-kernel@vger.kernel.org, t.artem@lycos.com, linux-mm@kvack.org, mgorman@suse.de, tytso@mit.edu, fengguang.wu@intel.com, torvalds@linux-foundation.org, mpatlasov@parallels.com

On Fri, 01 Nov 2013 18:31:40 +0400 Maxim Patlasov <MPatlasov@parallels.com> wrote:

> "strictlimit" feature was introduced to enforce per-bdi dirty limits for
> FUSE which sets bdi max_ratio to 1% by default:
> 
> http://www.http.com//article.gmane.org/gmane.linux.kernel.mm/105809
> 
> However the feature can be useful for other relatively slow or untrusted
> BDIs like USB flash drives and DVD+RW. The patch adds a knob to enable the
> feature:
> 
> echo 1 > /sys/class/bdi/X:Y/strictlimit
> 
> Being enabled, the feature enforces bdi max_ratio limit even if global (10%)
> dirty limit is not reached. Of course, the effect is not visible until
> max_ratio is decreased to some reasonable value.

I suggest replacing "max_ratio" here with the much more informative
"/sys/class/bdi/X:Y/max_ratio".

Also, Documentation/ABI/testing/sysfs-class-bdi will need an update
please.

>  mm/backing-dev.c |   35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 

I'm not really sure what to make of the patch.  I assume you tested it
and observed some effect.  Could you please describe the test setup and
the effects in some detail?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
