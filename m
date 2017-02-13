Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B264B6B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:42:32 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id x128so44650154lfa.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:42:32 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id q11si6339908lfh.105.2017.02.13.07.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 07:42:31 -0800 (PST)
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz> <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
 <20170210075149.GA17166@kroah.com> <20170210075949.GB10893@dhcp22.suse.cz>
 <e836d455-2c12-d3a9-81f8-384194428c5f@sonymobile.com>
 <20170210091459.GF10893@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <375245cc-11ba-4c93-9afa-5332cf43bec6@sonymobile.com>
Date: Mon, 13 Feb 2017 16:42:16 +0100
MIME-Version: 1.0
In-Reply-To: <20170210091459.GF10893@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Riley Andrews <riandrews@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 02/10/2017 10:15 AM, Michal Hocko wrote:
> On Fri 10-02-17 10:05:34, peter enderborg wrote:
>> On 02/10/2017 08:59 AM, Michal Hocko wrote:
> [...]
>>> The approach was wrong from the day 1. Abusing slab shrinkers
>>> is just a bad place to stick this logic. This all belongs to the
>>> userspace.
>> But now it is there and we have to stick with it.
> It is also adding maintenance cost. Just have a look at the git log and
> check how many patches were just a result of the core changes which
> needed a sync.
>
> I seriously doubt that any of the android devices can run natively on
> the Vanilla kernel so insisting on keeping this code in staging doesn't
> give much sense to me.

I guess that we more than a few that would like to see that.

We have

http://developer.sonymobile.com/open-devices/how-to-build-and-flash-a-linux-kernel/how-to-build-mainline-linux-for-xperia-devices/

It is not the latest on anything and it is not on par with commercial bundled software.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
