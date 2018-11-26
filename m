Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E84D6B4150
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:06:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c53so9018282edc.9
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 01:06:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21-v6sor32851ejh.52.2018.11.26.01.06.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 01:06:55 -0800 (PST)
Date: Mon, 26 Nov 2018 09:06:54 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181126090654.hgazohtksychaaf3@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
 <20181121025231.ggk7zgq53nmqsqds@master>
 <20181121071549.GG12932@dhcp22.suse.cz>
 <CADZGycYghU=_vXR759mwFhvV=7KKu3z3h1FyWb4OeEMeOY5isg@mail.gmail.com>
 <20181126081608.GE12455@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126081608.GE12455@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 26, 2018 at 09:16:08AM +0100, Michal Hocko wrote:
>On Mon 26-11-18 10:28:40, Wei Yang wrote:
>[...]
>> But I get some difficulty to understand this TODO. You want to get rid of
>> these lock? While these locks seem necessary to protect those data of
>> pgdat/zone. Would you mind sharing more on this statement?
>
>Why do we need this lock to be irqsave? Is there any caller that uses
>the lock from the IRQ context?

I see you put the comment 'irqsave' in code, I thought this is the
requirement bringing in by this commit. So this is copyed from somewhere
else?

>From my understanding, we don't access pgdat from interrupt context.

BTW, one more confirmation. One irqsave lock means we can't do something
during holding the lock, like sleep. Is my understanding correct?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
