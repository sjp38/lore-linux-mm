Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD286B025E
	for <linux-mm@kvack.org>; Mon,  9 May 2016 09:01:34 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id kj7so242765408igb.3
        for <linux-mm@kvack.org>; Mon, 09 May 2016 06:01:34 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0120.outbound.protection.outlook.com. [157.56.112.120])
        by mx.google.com with ESMTPS id s131si12082168oie.110.2016.05.09.06.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 May 2016 06:01:25 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm, kasan: improve double-free detection
References: <20160506114727.GA2571@cherokee.in.rdlabs.hpecorp.net>
 <573065BD.2020708@virtuozzo.com>
 <20E775CA4D599049A25800DE5799F6DD1F627919@G4W3225.americas.hpqcorp.net>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57308A20.2050501@virtuozzo.com>
Date: Mon, 9 May 2016 16:01:20 +0300
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F627919@G4W3225.americas.hpqcorp.net>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 05/09/2016 02:35 PM, Luruo, Kuthonuzo wrote:
> 
> This patch with atomic bit op is similar in spirit to v1 except that it increases metadata size.
> 

I don't think that this is a big deal. That will slightly increase size of objects <= (128 - 32) bytes.
And if someone think otherwise, we can completely remove 'alloc_size'
(we use it only to print size in report - not very useful).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
