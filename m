Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB986B2BA6
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 09:28:32 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w15so4599783edl.21
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 06:28:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15-v6sor11916834eju.2.2018.11.22.06.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 06:28:31 -0800 (PST)
Date: Thu, 22 Nov 2018 14:28:30 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181122142830.mdvmclgd3fuqkhdt@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <1542883058.3081.0.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542883058.3081.0.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Nov 22, 2018 at 11:37:38AM +0100, osalvador wrote:
>On Thu, 2018-11-22 at 18:12 +0800, Wei Yang wrote:
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>Thanks ;-)
>

Thanks for your suggestions :-)

>Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Wei Yang
Help you, Help me
