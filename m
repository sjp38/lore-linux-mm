Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBEFC6B025F
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 16:52:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p64so426050231pfb.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 13:52:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m75si35319568pfa.29.2016.07.25.13.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 13:52:01 -0700 (PDT)
Date: Mon, 25 Jul 2016 13:51:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mem-hotplug: alloc new page from a nearest neighbor
 node when mem-offline
Message-Id: <20160725135159.d8f06042d91a5b5d1e5c4ebf@linux-foundation.org>
In-Reply-To: <5795E18B.5060302@huawei.com>
References: <5795E18B.5060302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, 25 Jul 2016 17:53:15 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Subject: [PATCH v3] mem-hotplug: alloc new page from a nearest neighbor node when mem-offline

argh.

This is "v3" but there is no v1 and no v2.  Please don't change the
name of patches in this manner.  Or if you do, please be clear which
patch is being updated.

I'll drop your
mem-hotplug-use-different-mempolicy-in-alloc_migrate_target.patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
