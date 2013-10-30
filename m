Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C52376B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 04:42:32 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so616187pad.37
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 01:42:32 -0700 (PDT)
Received: from psmtp.com ([74.125.245.112])
        by mx.google.com with SMTP id z1si17176172pbw.309.2013.10.30.01.42.19
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 01:42:20 -0700 (PDT)
Message-ID: <5270C666.6090209@iki.fi>
Date: Wed, 30 Oct 2013 10:42:14 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2 13/15] slab: use struct page for slab management
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com> <20131030082800.GA5753@lge.com>
In-Reply-To: <20131030082800.GA5753@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 10/30/2013 10:28 AM, Joonsoo Kim wrote:
> If you want an incremental patch against original patchset,
> I can do it. Please let me know what you want.

Yes, please. Incremental is much easier to deal with if we want this to 
end up in v3.13.

                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
