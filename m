Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B49056B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:41:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so31495058lfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:41:49 -0700 (PDT)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id tk4si10386118wjb.199.2016.06.17.00.41.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 00:41:48 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: Don't blindly assign fallback_migrate_page()
References: <1466112375-1717-1-git-send-email-richard@nod.at>
 <1466112375-1717-2-git-send-email-richard@nod.at>
 <20160616161121.35ee5183b9ef9f7b7dcbc815@linux-foundation.org>
From: Richard Weinberger <richard@nod.at>
Message-ID: <5763A9B2.8060303@nod.at>
Date: Fri, 17 Jun 2016 09:41:38 +0200
MIME-Version: 1.0
In-Reply-To: <20160616161121.35ee5183b9ef9f7b7dcbc815@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, adrian.hunter@intel.com, dedekind1@gmail.com, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

Andrew,

Am 17.06.2016 um 01:11 schrieb Andrew Morton:
> On Thu, 16 Jun 2016 23:26:13 +0200 Richard Weinberger <richard@nod.at> wrote:
> 
>> While block oriented filesystems use buffer_migrate_page()
>> as page migration function other filesystems which don't
>> implement ->migratepage() will automatically get fallback_migrate_page()
>> assigned. fallback_migrate_page() is not as generic as is should
>> be. Page migration is filesystem specific and a one-fits-all function
>> is hard to achieve. UBIFS leaned this lection the hard way.
>> It uses various page flags and fallback_migrate_page() does not
>> handle these flags as UBIFS expected.
>>
>> To make sure that no further filesystem will get confused by
>> fallback_migrate_page() disable the automatic assignment and
>> allow filesystems to use this function explicitly if it is
>> really suitable.
> 
> hm, is there really much point in doing this?  I assume it doesn't
> actually affect any current filesystems?

Well, we simply don't know which filesystems are affected by similar issues.
JFFS2 is maybe also affected since it is not block based.
For UBIFS it also worked many years.

> [2/3] is of course OK - please add it to the UBIFS tree.

Can I add your Acked-by?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
