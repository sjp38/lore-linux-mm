Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39AC36B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 21:27:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so45030116wmp.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 18:27:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si3490845wjk.212.2016.07.22.18.27.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 18:27:13 -0700 (PDT)
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
From: Tony Jones <tonyj@suse.de>
Message-ID: <9c67941f-05f0-0d3e-ecc8-dcea60254c8b@suse.de>
Date: Fri, 22 Jul 2016 18:27:07 -0700
MIME-Version: 1.0
In-Reply-To: <20160720145405.GP11249@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/20/2016 07:54 AM, Michal Hocko wrote:

>> Michal, just to make sure I understand you correctly, do you mean that we
>> could infer the names of the shrinkers by looking at the names of their callbacks?
> 
> Yes, %ps can then be used for the name of the shrinker structure
> (assuming it is available).

This is fine for emitting via the ftrace /sys interface,  but in order to have the data [name] get 
marshalled thru to perf (for example) you need to add it to the TP_fast_assign entry.

tony



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
