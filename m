Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5710280422
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 12:40:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o77so9531245qke.1
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 09:40:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor144283qkd.119.2017.09.06.09.40.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Sep 2017 09:40:18 -0700 (PDT)
Date: Wed, 6 Sep 2017 09:40:15 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] workqueue: use type int instead of bool to index
 array
Message-ID: <20170906164015.GQ1774378@devbig577.frc2.facebook.com>
References: <59AF6CB6.4090609@zoho.com>
 <20170906143320.GK1774378@devbig577.frc2.facebook.com>
 <c795e42f-8355-b79b-3239-15c4ea8fede7@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c795e42f-8355-b79b-3239-15c4ea8fede7@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, jiangshanlai@gmail.com

On Thu, Sep 07, 2017 at 12:04:59AM +0800, zijun_hu wrote:
> On 2017/9/6 22:33, Tejun Heo wrote:
> > Hello,
> > 
> > On Wed, Sep 06, 2017 at 11:34:14AM +0800, zijun_hu wrote:
> >> From: zijun_hu <zijun_hu@htc.com>
> >>
> >> type bool is used to index three arrays in alloc_and_link_pwqs()
> >> it doesn't look like conventional.
> >>
> >> it is fixed by using type int to index the relevant arrays.
> > 
> > bool is a uint type which can be either 0 or 1.  I don't see what the
> > benefit of this patch is.q
> > 
> bool is NOT a uint type now, it is a new type introduced by gcc, it is
> rather different with "typedef int bool" historically

http://www.open-std.org/jtc1/sc22/wg14/www/docs/n815.htm

  Because C has existed for so long without a Boolean type, however, the
  new standard must coexist with the old remedies. Therefore, the type
  name is taken from the reserved identifier space. To maintain
  orthogonal promotion rules, the Boolean type is defined as an unsigned
  integer type capable of representing the values 0 and 1. The more
  conventional names for the type and its values are then made available
  only with the inclusion of the <stdbool.h> header. In addition, the
  header defines a feature test macro to aid in integrating new code
  with old code that defines its own Boolean type.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
