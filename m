Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19F5C6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:26:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o70so55066046wrb.11
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 13:26:55 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id k6si4511674wma.165.2017.03.28.13.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 13:26:53 -0700 (PDT)
Date: Tue, 28 Mar 2017 13:26:52 -0700
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [LTP] Is MADV_HWPOISON supposed to work only on faulted-in pages?
Message-ID: <20170328202652.GC8285@two.firstfloor.org>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <87zig6uvgd.fsf@firstfloor.org>
 <20170328082506.GA30388@rei>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328082506.GA30388@rei>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

> Well I disagree, the reason why the test fails is that MADV_HWPOISON on
> not-faulted private mappings fails silently, which is a bug, albeit
> minor one. If something is not implemented, it should report a failure,
> the usual error return would be EINVAL in this case.
> 
> It appears that it fails with EBUSY on first try on newer kernels, but
> still fails silently when we try for a second time.
> 
> Why can't we simply check if the page is faulted or not and return error
> in the latter case?

It's a debug interface. You're supposed to know what you're doing.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
