Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4CD6B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 11:30:20 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id x28so668100uab.7
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 08:30:20 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id g65si251067vkh.82.2017.04.26.08.30.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 08:30:19 -0700 (PDT)
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
Date: Wed, 26 Apr 2017 18:29:08 +0300
MIME-Version: 1.0
In-Reply-To: <20170426144750.GH12504@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 26/04/17 17:47, Michal Hocko wrote:
> On Wed 26-04-17 16:35:49, Igor Stoppa wrote:
>> The bitmasks used for ___GFP_xxx can be defined in terms of an enum,
>> which doesn't require manual updates to its values.
> 
> GFP masks are rarely updated so why is this worth doing?

I have plans for that [1] - yeah, I should have not written only to ml -
but I thought there was sufficient value in this patch to be sent alone.

I got into this part of the code because (if I understood correctly)
there are no spare bits available from the 32bits mask that is currently
in use.

Adding a new zone, therefore, would cause the bumping to a 64bits type.
If the zone is not strictly needed, some people might prefer to have the
option to stick to 32 bits.

Which in turn would mean more #ifdefs.

Using the enum should provide the same flexibility with a more limited
number of #ifdefs in the code.

But I really thought that there is a value in the change per-se.
Regardless of what other patches might follow.


>> As bonus, __GFP_BITS_SHIFT is automatically kept consistent.
> 
> this alone doesn't sound like a huge win to me, to be honest. We already
> have ___GFP_$FOO and __GFP_FOO you are adding __GFP_$FOO_SHIFT. This is
> too much IMHO.

I do not like the #defines being floating and potentially inconsistent
with the rest, when they are supposed to represent all the individual
bits in a bitmask.
One might argue that an error will be detected fairly soon, but to me
using an enum to automatically manage the values and counter of items
seems preferable.

> Also the current mm tree has ___GFP_NOLOCKDEP which is not addressed
> here so I suspect you have based your change on the Linus tree.

I used your tree from kernel.org - I asked yesterday on #mm if it was a
good idea and was told that it should be ok, so I did it, but I can redo
the patch with mm.


If you prefer to have this patch only as part of the larger patchset,
I'm also fine with it.
Also, if you could reply to [1], that would be greatly appreciated.

Maybe I'm starting from some wrong assumption or there is a better way
to achieve what I want.


thanks, igor

[1] http://marc.info/?l=linux-mm&m=149276346722464&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
