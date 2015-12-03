Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2EB46B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 14:28:04 -0500 (EST)
Received: by wmww144 with SMTP id w144so36195401wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 11:28:04 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k129si571892wma.26.2015.12.03.11.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 11:28:03 -0800 (PST)
Date: Thu, 3 Dec 2015 14:27:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/memcontrol.c: use list_{first,next}_entry
Message-ID: <20151203192750.GA19242@cmpxchg.org>
References: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
 <20151203162718.GK9264@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203162718.GK9264@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Geliang Tang <geliangtang@163.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 03, 2015 at 05:27:18PM +0100, Michal Hocko wrote:
> On Thu 03-12-15 22:16:55, Geliang Tang wrote:
> > To make the intention clearer, use list_{first,next}_entry instead
> > of list_entry.
> 
> Does this really help readability? This function simply uncharges the
> given list of pages. Why cannot we simply use list_for_each_entry
> instead...

You asked the same thing when reviewing the patch for the first
time. :-) I think it's time to add a comment.
