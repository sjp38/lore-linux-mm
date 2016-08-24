Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED9F56B0263
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 17:14:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so54089236pfx.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 14:14:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xe10si11390690pab.50.2016.08.24.14.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 14:14:20 -0700 (PDT)
Date: Wed, 24 Aug 2016 14:14:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [wrecked]
 mm-compaction-more-reliably-increase-direct-compaction-priority.patch
 removed from -mm tree
Message-Id: <20160824141418.b266d5a0bddf9170181f8627@linux-foundation.org>
In-Reply-To: <20160824070859.GC31179@dhcp22.suse.cz>
References: <57bcb948./5Xz5gcuIQjtLmuG%akpm@linux-foundation.org>
	<20160824070859.GC31179@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, riel@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Wed, 24 Aug 2016 09:08:59 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Hi Andrew,
> I guess the reason this patch has been dropped is due to
> mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch.

Yes.  And I think we're still waiting testing feedback from the
reporters on
mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch?

> I guess we will wait for the above patch to get to Linus, revert it in mmotm
> and re-apply
> mm-compaction-more-reliably-increase-direct-compaction-priority.patch
> again, right?

I suppose so.  We can leave
mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch
in place in mainline for 4.8 so it can be respectably backported into
-stable.

And we may as well fold
mm-compaction-more-reliably-increase-direct-compaction-priority.patch
into the patch which re-adds should_compact_retry()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
