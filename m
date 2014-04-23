Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id E35626B0070
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 02:41:40 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id as1so512865iec.39
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 23:41:40 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id bo3si36097icc.10.2014.04.22.23.41.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 23:41:40 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so3972162igq.10
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 23:41:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422124920.e22ed65d33d2b982ef467372@linux-foundation.org>
References: <cover.1398147734.git.nasa4836@gmail.com> <2c63c535f8202c6b605300a834cdf1c07d1bafc3.1398147734.git.nasa4836@gmail.com>
 <20140422124920.e22ed65d33d2b982ef467372@linux-foundation.org>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Wed, 23 Apr 2014 14:41:00 +0800
Message-ID: <CAHz2CGUV7HQYkKzwhw-JNiwHTHX8Djp-ReC23i+=1jaM1YaowQ@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/memcontrol.c: use accessor to get id from css
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Tejun Heo <tj@kernel.org>

On Wed, Apr 23, 2014 at 3:49 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> I'd expect Tejun to process this series, but you didn't cc him on 2/4.

Oh, I reposed too much confidence in get_maintainer.pl.  I thought it
would cc tj as usual. :-)

Tj said he has a patchset queued for addressing this problem and will
be sent out soon,
so just forget this patch and wait.


Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
