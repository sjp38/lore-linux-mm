Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 073966B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 16:28:19 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id r90so150795708qki.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:28:19 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id k1si7863734qtk.215.2017.02.27.13.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 13:28:18 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id 203so7140941ywz.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:28:18 -0800 (PST)
Date: Mon, 27 Feb 2017 16:28:16 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/3] percpu: improve allocation success rate for
 non-GFP_KERNEL callers
Message-ID: <20170227212816.GB11758@htj.duckdns.org>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com>
 <20170226043829.14270-1-tahsin@google.com>
 <20170227095258.GG14029@dhcp22.suse.cz>
 <CAAeU0aMaGa63Nj=JvZKKy82FftAT9dF56=gZsufDvrkqDSGUrw@mail.gmail.com>
 <20170227195126.GC8707@htj.duckdns.org>
 <CAAeU0aORY=N0e0gMKu-CBAEF=HLuHUNV6KWy27th1rwuPMcTMg@mail.gmail.com>
 <20170227202906.GF8707@htj.duckdns.org>
 <CAAeU0aMnz-nsXGy44mwBfzwfFJtVWNRQiAE0UAonBQA3iDJBqg@mail.gmail.com>
 <20170227204527.GG8707@htj.duckdns.org>
 <CAAeU0aPGvoYr=dtbRWT3=S5x9HmkUEiGmGWQy0JdFVu3F40N9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeU0aPGvoYr=dtbRWT3=S5x9HmkUEiGmGWQy0JdFVu3F40N9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 27, 2017 at 01:12:11PM -0800, Tahsin Erdogan wrote:
> That makes sense. I will work a patch that does that (unless you are
> interested in implementing it yourself).

I'd really appreciate if you can work on it.  Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
