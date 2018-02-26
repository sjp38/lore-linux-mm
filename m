Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8B16B0003
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 15:15:04 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a143so13379492qkg.4
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 12:15:04 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e9si10210986qkh.274.2018.02.26.12.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 12:15:03 -0800 (PST)
Date: Mon, 26 Feb 2018 15:15:02 -0500 (EST)
Message-Id: <20180226.151502.1181392845403505211.davem@redhat.com>
Subject: Re: [PATCH 0/2] mark some slabs as visible not mergeable
From: David Miller <davem@redhat.com>
In-Reply-To: <20180224190454.23716-1-sthemmin@microsoft.com>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stephen@networkplumber.org
Cc: willy@infradead.org, netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, sthemmin@microsoft.com

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 24 Feb 2018 11:04:52 -0800

> This fixes an old bug in iproute2's ss command because it was
> reading slabinfo to get statistics. There isn't a better API
> to do this, and one can argue that /proc is a UAPI that must
> not change.

Please elaborate what kind of statistics are needed.

> Therefore this patch set adds a flag to slab to give another
> reason to prevent merging, and then uses it in network code.
> 
> The patches are against davem's linux-net tree and should also
> goto stable as well.

Well, as has been pointed out this never worked with SLUB so
in some sense this was always broken.

And the "UAPI" of slabinfo is to show the state of the various
slab caches.  And that's it.

If the implementation does merging or whatever, the UAPI is expressing
that and it's perfectly legitimate and not breaking UAPI in my
opinion.

I think the better solution is to grab the information from somewhere
else, so let's move this conversation along with the answer to my
question about asking for more details about what is needed by
iproute2.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
