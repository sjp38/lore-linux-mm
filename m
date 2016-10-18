Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B32EB6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:51:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so223573621pfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:51:23 -0700 (PDT)
Received: from mx0b-0016f401.pphosted.com (mx0a-0016f401.pphosted.com. [67.231.148.174])
        by mx.google.com with ESMTPS id r1si3000943paz.327.2016.10.18.04.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 04:51:23 -0700 (PDT)
Date: Tue, 18 Oct 2016 19:21:49 +0800
From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [RFC] reduce latency in __purge_vmap_area_lazy
Message-ID: <20161018192149.3de86109@xhacker>
In-Reply-To: <1476773771-11470-1-git-send-email-hch@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, 18 Oct 2016 08:56:05 +0200 Christoph Hellwig wrote:

> Hi all,
> 
> this is my spin at sorting out the long lock hold times in
> __purge_vmap_area_lazy.  It is based on the patch from Joel sent this
> week.  I don't have any good numbers for it, but it survived an
> xfstests run on XFS which is a significant vmalloc user.  The
> changelogs could still be improved as well, but I'd rather get it
> out quickly for feedback and testing.

I just tested this series, the preempt off ftrace log doesn't complain
__purge_vmap_area_lazy any more in my test case, this latency is removed!

So feel free to add

Tested-by: Jisheng Zhang <jszhang@marvell.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
