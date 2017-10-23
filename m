Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 123116B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:27:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g10so8552719wrg.6
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:27:54 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f17si5143646wrc.29.2017.10.23.03.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 03:27:53 -0700 (PDT)
Date: Mon, 23 Oct 2017 12:26:47 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH 01/15] sched: convert sighand_struct.count to
 refcount_t
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B802B4359@IRSMSX102.ger.corp.intel.com>
Message-ID: <alpine.DEB.2.20.1710231223450.4241@nanos>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com> <1508501757-15784-2-git-send-email-elena.reshetova@intel.com> <alpine.DEB.2.20.1710201430420.4531@nanos> <2236FBA76BA1254E88B949DDB74E612B802B4359@IRSMSX102.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "tj@kernel.org" <tj@kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "lizefan@huawei.com" <lizefan@huawei.com>, "acme@kernel.org" <acme@kernel.org>, "alexander.shishkin@linux.intel.com" <alexander.shishkin@linux.intel.com>, "eparis@redhat.com" <eparis@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "luto@kernel.org" <luto@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "dvhart@infradead.org" <dvhart@infradead.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Mon, 23 Oct 2017, Reshetova, Elena wrote:
> > On Fri, 20 Oct 2017, Elena Reshetova wrote:
> > How did you make sure that these atomic operations have no other
> > serialization effect and can be replaced with refcount?
> 
> What serialization effects? Are you taking about smth else than memory
> ordering? 

Well, the memory ordering constraints can be part of serialization
mechanisms. Unfortunately they are not well documented ....

> For memory ordering my current hope is that we can just make refcount_t
> to use same strict atomic primitives and then it would not make any
> difference.  I think this would be the simplest way for everyone since I
> think even some maintainers are having issues understanding all the
> implications of "relaxed" ordering.

Well, that would make indeed the conversion simpler because then it is just
a drop in replacement. Albeit there might be some places which benefit of
the relaxed ordering as on some architectures strict ordering is expensive.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
