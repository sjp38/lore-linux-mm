Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F31E6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:30:10 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id g19so2581644lfh.1
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:30:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor3161250ljb.80.2017.12.20.01.30.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 01:30:08 -0800 (PST)
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz> <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
 <20171220083403.GC11774@jagdpanzerIV> <20171220090828.GB4831@dhcp22.suse.cz>
 <20171220091653.GE11774@jagdpanzerIV> <20171220092513.GF4831@dhcp22.suse.cz>
From: A K <akaraliou.dev@gmail.com>
Message-ID: <06247d4c-82a7-ccf1-ad42-4ef751081011@gmail.com>
Date: Wed, 20 Dec 2017 12:30:06 +0300
MIME-Version: 1.0
In-Reply-To: <20171220092513.GF4831@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On 12/20/2017 12:25 PM, Michal Hocko wrote:

> On Wed 20-12-17 18:16:53, Sergey Senozhatsky wrote:
>> On (12/20/17 10:08), Michal Hocko wrote:
>> [..]
>>>> let's keep void zs_register_shrinker() and just suppress the
>>>> register_shrinker() must_check warning.
>>> I would just hope we simply drop the must_check nonsense.
>> agreed. given that unregister_shrinker() does not oops anymore,
>> enforcing that check does not make that much sense.
> Well, the registration failure is a failure like any others. Ignoring
> the failure can have bad influence on the overal system behavior but
> that is no different from thousands of other functions. must_check is an
> overreaction here IMHO.
Fine, then I'll resend the patch with diff from Andrew, and also I'd like
to move the improved comment into zs_register_shrinker().

Best regards,
    Aliaksei.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
