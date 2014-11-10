Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 436F76B0112
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 12:03:08 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so8498709pab.26
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 09:03:08 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rc17si17086217pab.100.2014.11.10.09.03.05
        for <linux-mm@kvack.org>;
        Mon, 10 Nov 2014 09:03:06 -0800 (PST)
Message-ID: <5460EFC9.7060906@intel.com>
Date: Mon, 10 Nov 2014 09:03:05 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc/smaps: add proportional size of anonymous page
References: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com> <545D3AFB.1080308@intel.com> <6212C327DC2094488C1AAAD903AF062B01BCE1E6@SHSMSX104.ccr.corp.intel.com>
In-Reply-To: <6212C327DC2094488C1AAAD903AF062B01BCE1E6@SHSMSX104.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Qin, Xiaokang" <xiaokang.qin@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Yin, Fengwei" <fengwei.yin@intel.com>

On 11/10/2014 12:48 AM, Qin, Xiaokang wrote:
> For some case especially under Android, anonymous page sharing is common, for example:
> 70323000-70e41000 rw-p 00000000 fd:00 120004                             /data/dalvik-cache/x86/system@framework@boot.art
> Size:              11384 kB
> Rss:                8840 kB
> Pss:                 927 kB
> Shared_Clean:       5720 kB
> Shared_Dirty:       2492 kB
> Private_Clean:        16 kB
> Private_Dirty:       612 kB
> Referenced:         7896 kB
> Anonymous:          3104 kB
> PropAnonymous:       697 kB

Please don't top post.

> The only Anonymous here is confusing to me. What I really want to
> know is how many anonymous page is there in Pss. After exposing
> PropAnonymous, we could know 697/927 is anonymous in Pss.
> I suppose the Pss - PropAnonymous = Proportional Page cache size for
> file based memory and we want to break down the page cache into
> process level, how much page cache each process consumes.

Ahh, so you're talking about the anonymous pages that result from
copy-on-write copies of private file mappings?  That wasn't very clear
from the description at all.

I'll agree that this definitely provides a bit of data that we didn't
have before, albeit a fairly obscure one.

But, what's the goal of this patch?  Why are you doing this?  Was there
some application whose behavior you were not able to explain before, but
can after this patch?  If the goal is providing a "Proportional Page
cache size", why do that in an indirect way?  Have you explored doing
the same measurement with /proc/$pid/pagemap?  Is it possible with that
interface?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
