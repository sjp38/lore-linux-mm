Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 128786B0388
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 04:05:57 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id o12so11388968lfg.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 01:05:57 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id n3si685850lfd.347.2017.02.10.01.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 01:05:55 -0800 (PST)
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz> <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
 <20170210075149.GA17166@kroah.com> <20170210075949.GB10893@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <e836d455-2c12-d3a9-81f8-384194428c5f@sonymobile.com>
Date: Fri, 10 Feb 2017 10:05:34 +0100
MIME-Version: 1.0
In-Reply-To: <20170210075949.GB10893@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Riley Andrews <riandrews@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 02/10/2017 08:59 AM, Michal Hocko wrote:
> On Fri 10-02-17 08:51:49, Greg KH wrote:
>> On Fri, Feb 10, 2017 at 08:21:32AM +0100, peter enderborg wrote:
> [...]
>>> Until then we have to polish this version as good as we can. It is
>>> essential for android as it is now.
>> But if no one is willing to do the work to fix the reported issues, why
>> should it remain?  Can you do the work here?  You're already working on
>> fixing some of the issues in a differnt way, why not do the "real work"
>> here instead for everyone to benifit from?
> Well, to be honest, I do not think that the current code is easily
> fixable. 
This patch improves the current situation and address some
of the issues that makes android devices behaviour different
than other linux systems.
> The approach was wrong from the day 1. Abusing slab shrinkers
> is just a bad place to stick this logic. This all belongs to the
> userspace.
But now it is there and we have to stick with it.
>  For that we need a proper mm pressure notification which is
> supposed to be vmpressure but that one also doesn't seem to work all
> that great. So rather than trying to fix unfixable I would stronly
> suggest focusing on making vmpressure work reliably.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
