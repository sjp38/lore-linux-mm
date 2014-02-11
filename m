Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8686B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 17:49:38 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so2440842bkg.33
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 14:49:38 -0800 (PST)
Received: from mail-bk0-x235.google.com (mail-bk0-x235.google.com [2a00:1450:4008:c01::235])
        by mx.google.com with ESMTPS id qw9si14368450bkb.1.2014.02.11.14.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 14:49:36 -0800 (PST)
Received: by mail-bk0-f53.google.com with SMTP id my13so2400385bkb.40
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 14:49:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140210150614.c6a1b20553803da5f81acb72@linux-foundation.org>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <1390831279-5525-1-git-send-email-ddstreet@ieee.org> <20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
 <CALZtONAFF3F4j0KQX=ineJ1cOVEWJSGSe3V=Ja4x=3NguFAFMQ@mail.gmail.com> <20140210150614.c6a1b20553803da5f81acb72@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 11 Feb 2014 17:49:15 -0500
Message-ID: <CALZtONAHNzvOmNgY99i+QJcZFqdtxEgdmCck8h37vwYxfGTQPg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: add writethrough option
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On Mon, Feb 10, 2014 at 6:06 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 10 Feb 2014 14:05:14 -0500 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> >
>> > It does sound like the feature is of marginal benefit.  Is "zswap
>> > filled up" an interesting or useful case to optimize?
>> >
>> > otoh the addition is pretty simple and we can later withdraw the whole
>> > thing without breaking anyone's systems.
>>
>> ping...
>>
>> you still thinking about this or is it a reject for now?
>
> I'm not seeing a compelling case for merging it and Minchan sounded
> rather unconvinced.  Perhaps we should park it until/unless a more
> solid need is found?


Sounds good.  I'll bring it back up if I find some solid need for it.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
