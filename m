Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 336296B0390
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 19:54:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r129so82925844pgr.18
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 16:54:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t6si2091487plj.122.2017.03.27.16.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 16:54:43 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
	<20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
	<20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
Date: Mon, 27 Mar 2017 16:54:42 -0700
In-Reply-To: <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp> (Naoya
	Horiguchi's message of "Thu, 23 Feb 2017 03:23:49 +0000")
Message-ID: <87zig6uvgd.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Jan Stancek <jstancek@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>
> I think that what the testcase effectively does is to test whether memory
> handling on zero pages works or not.
> And the testcase's failure seems acceptable, because it's simply not-implemented yet.
> Maybe recovering from error on zero page is possible (because there's no data
> loss for memory error,) but I'm not sure that code might be simple enough and/or
> it's worth doing ...

I doubt it's worth doing, it's just too unlikely that a specific page
is hit. Memory error handling is all about probabilities.

The test is just broken and should be fixed.

mce-test had similar problems at some point, but they were all fixed.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
