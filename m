Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B69B6B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 19:21:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b65so55881669wmg.0
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 16:21:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qu8si8260405wjb.96.2016.07.23.16.21.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 16:21:58 -0700 (PDT)
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <9c67941f-05f0-0d3e-ecc8-dcea60254c8b@suse.de>
 <8663a3c5-7b9b-c5b5-cddd-224e97171921@suse.de>
 <1469303017.30053.104.camel@surriel.com>
From: Tony Jones <tonyj@suse.de>
Message-ID: <bb157f59-ad25-30da-e8a8-86d8145f4e04@suse.de>
Date: Sat, 23 Jul 2016 16:21:46 -0700
MIME-Version: 1.0
In-Reply-To: <1469303017.30053.104.camel@surriel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>, Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/23/2016 12:43 PM, Rik van Riel wrote:

> Janani,

> it may make sense to have the code Tony posted be part of
> your patch series. Just have both of your Signed-off-by:
> lines on that patch.

Rik

Unfortunately the previous patch doesn't work on my system, which was the point I was trying to make. None of the shrinker symbols appear known so nothing usefully symbolic is displayed either with %ps 
or in the case of code I attached (calling sprint_symbol so it's visible to perf).   

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
