Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0187D6B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:37:00 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id z12so410867wgg.15
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:37:00 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id lq4si11991592wjb.143.2013.11.21.14.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 14:37:00 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id k14so669096wgh.3
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:37:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfMdOQ+DKiYEVBpP54RZYQWS_-7Xgf2YTA5jAZRxWsE6ag@mail.gmail.com>
References: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
 <20131120173347.GA2369@hp530> <CALZtONA81=R4abFMpMMtDZKQe0s-8+JxvEfZO3NEZ910VwRDmw@mail.gmail.com>
 <CAL1ERfMdOQ+DKiYEVBpP54RZYQWS_-7Xgf2YTA5jAZRxWsE6ag@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 17:36:40 -0500
Message-ID: <CALZtONARufrC-S0z8sdZ21LVfauvPiDDn23bO3fMfp5w4o28Qw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: change params from hidden to ro
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Vladimir Murzin <murzin.v@gmail.com>, linux-mm@kvack.org, Seth Jennings <sjennings@variantweb.net>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 10:12 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> On Thu, Nov 21, 2013 at 1:52 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> On Wed, Nov 20, 2013 at 12:33 PM, Vladimir Murzin <murzin.v@gmail.com> wrote:
>>> Hi Dan!
>>>
>>> On Wed, Nov 20, 2013 at 11:38:42AM -0500, Dan Streetman wrote:
>>>> The "compressor" and "enabled" params are currently hidden,
>>>> this changes them to read-only, so userspace can tell if
>>>> zswap is enabled or not and see what compressor is in use.
>>>
>>> Could you elaborate more why this pice of information is necessary for
>>> userspace?
>>
>> For anyone interested in zswap, it's handy to be able to tell if it's
>> enabled or not ;-)  Technically people can check to see if the zswap
>> debug files are in /sys/kernel/debug/zswap, but I think the actual
>> "enabled" param is more obvious.  And the compressor param is really
>> the only way anyone from userspace can see what compressor's being
>> used; that's helpful to know for anyone that might want to be using a
>> non-default compressor.
>>
>> And of course, eventually we'll want to make the params writable, so
>> the compressor can be changed dynamically, and zswap can be enabled or
>> disabled dynamically (or at least enabled after boot).
>
> Please do not make them writable.

This patch doesn't make them writable.

> There is no requirement to do that, and it will make zswap more complex.

I can't speak for others, but I personally think being able to at
least enable zswap after boot will be useful, as well as being able to
change the compressor after boot.  Obviously it will make zswap more
complex, but that's the nature of improving software ;-)

>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
