Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 910296B0025
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 21:33:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y97-v6so2097343plh.20
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 18:33:06 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id n6si8290268pgf.310.2018.03.24.18.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Mar 2018 18:33:05 -0700 (PDT)
Subject: Re: [PATCH 6/8] Pmalloc selftest
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-7-igor.stoppa@huawei.com>
 <20180314122512.GF29631@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <ce6e34a4-592d-624c-2353-20e50e321298@huawei.com>
Date: Sun, 25 Mar 2018 04:32:57 +0300
MIME-Version: 1.0
In-Reply-To: <20180314122512.GF29631@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 14/03/18 14:25, Matthew Wilcox wrote:
> On Tue, Mar 13, 2018 at 11:45:52PM +0200, Igor Stoppa wrote:
>> Add basic self-test functionality for pmalloc.
> 
> Here're some additional tests for your test-suite:
> 
> 	for (i = 1; i; i *= 2)
> 		pzalloc(pool, i - 1, GFP_KERNEL);
> 

Ok, I have almost finished the rewrite.
I still have to address this comment.

When I run the test, eventually the system runs out of memory, it keeps
getting allocation errors from vmalloc, until i finally overflows and
becomes 0.

Am I supposed to do something about it?
If pmalloc receives a request that the vmalloc backend cannot satisfy, I
would prefer that vmalloc itself produces the warning and pmalloc
returns NULL.

This doesn't look like a test case that one can leave always enabled in
a build, but maybe I'm missing the point.

--
igor
