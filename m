Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4F76B005A
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:53:11 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so2308066pdj.12
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:53:11 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id it5si14789903pbc.35.2013.11.20.09.53.09
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:53:10 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id f4so7443211wiw.9
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:53:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131120173347.GA2369@hp530>
References: <1384965522-5788-1-git-send-email-ddstreet@ieee.org> <20131120173347.GA2369@hp530>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 20 Nov 2013 12:52:47 -0500
Message-ID: <CALZtONA81=R4abFMpMMtDZKQe0s-8+JxvEfZO3NEZ910VwRDmw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: change params from hidden to ro
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <murzin.v@gmail.com>
Cc: linux-mm@kvack.org, Seth Jennings <sjennings@variantweb.net>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 12:33 PM, Vladimir Murzin <murzin.v@gmail.com> wrote:
> Hi Dan!
>
> On Wed, Nov 20, 2013 at 11:38:42AM -0500, Dan Streetman wrote:
>> The "compressor" and "enabled" params are currently hidden,
>> this changes them to read-only, so userspace can tell if
>> zswap is enabled or not and see what compressor is in use.
>
> Could you elaborate more why this pice of information is necessary for
> userspace?

For anyone interested in zswap, it's handy to be able to tell if it's
enabled or not ;-)  Technically people can check to see if the zswap
debug files are in /sys/kernel/debug/zswap, but I think the actual
"enabled" param is more obvious.  And the compressor param is really
the only way anyone from userspace can see what compressor's being
used; that's helpful to know for anyone that might want to be using a
non-default compressor.

And of course, eventually we'll want to make the params writable, so
the compressor can be changed dynamically, and zswap can be enabled or
disabled dynamically (or at least enabled after boot).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
