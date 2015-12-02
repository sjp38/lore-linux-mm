Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D295E6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 16:04:28 -0500 (EST)
Received: by wmww144 with SMTP id w144so74353229wmw.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 13:04:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si6827055wjy.224.2015.12.02.13.04.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 13:04:27 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
 <1448899821-9671-1-git-send-email-vbabka@suse.cz>
 <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565F5CD9.9080301@suse.cz>
Date: Wed, 2 Dec 2015 22:04:25 +0100
MIME-Version: 1.0
In-Reply-To: <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On 12/02/2015 06:40 PM, yalin wang wrote:

(please trim your reply next time, no need to quote whole patch here)

> i am thinking why not make %pg* to be more generic ?
> not restricted to only GFP / vma flags / page flags .
> so could we change format like this ?
> define a flag spec struct to include flag and trace_print_flags and some other option :
> typedef struct { 
> unsigned long flag;
> struct trace_print_flags *flags;
> unsigned long option; } flag_sec;
> flag_sec my_flag;
> in printk we only pass like this :
> printk(a??%pg\na??, &my_flag) ;
> then it can print any flags defined by user .
> more useful for other drivers to use .

I don't know, it sounds quite complicated given that we had no flags printing
for years and now there's just three kinds of them. The extra struct flag_sec is
IMHO nuissance. No other printk format needs such thing AFAIK? For example, if I
were to print page flags from several places, each would have to define the
struct flag_sec instance, or some header would have to provide it?

I could maybe accept passing a flag value and trace_print_flags * as two
separate parameters, but I guess that breaks an ancient invariant of one
parameter per format string...

> Thanks
> 
> 
> 
> 
> 
> 
> 
> 
> 
>  
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
