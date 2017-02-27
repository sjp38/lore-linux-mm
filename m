Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2728E6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 16:12:13 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id f84so98601545ioj.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:12:13 -0800 (PST)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id l6si17384513iof.240.2017.02.27.13.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 13:12:12 -0800 (PST)
Received: by mail-it0-x236.google.com with SMTP id 203so74248450ith.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:12:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227204527.GG8707@htj.duckdns.org>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com> <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz> <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227195126.GC8707@htj.duckdns.org> <CAAeU0aORY=N0e0gMKu-CBAEF=HLuHUNV6KWy27th1rwuPMcTMg@mail.gmail.com>
 <20170227202906.GF8707@htj.duckdns.org> <CAAeU0aMnz-nsXGy44mwBfzwfFJtVWNRQiAE0UAonBQA3iDJBqg@mail.gmail.com>
 <20170227204527.GG8707@htj.duckdns.org>
From: Tahsin Erdogan <tahsin@google.com>
Date: Mon, 27 Feb 2017 13:12:11 -0800
Message-ID: <CAAeU0aPGvoYr=dtbRWT3=S5x9HmkUEiGmGWQy0JdFVu3F40N9g@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>> Doing preallocations would probably work but not sure if that can be
>> done without
>> complicating code too much. Could you describe what you have in mind?
>
> So, blkg_create() already takes @new_blkg argument which is the
> preallocated blkg and used during q init.  Wouldn't it work to make
> blkg_lookup_create() take @new_blkg too and pass it down to
> blkg_create() (and also free it if it doesn't get used)?  Then,
> blkg_conf_prep() can always (or after a failure with -ENOMEM) allocate
> a new blkg before calling into blkg_lookup_create().  I don't think
> it'll complicate the code path that much.

That makes sense. I will work a patch that does that (unless you are
interested in implementing it yourself).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
