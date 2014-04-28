Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id AD2A56B003A
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 11:55:28 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so4646152ier.26
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:55:28 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id gw5si13033573icb.202.2014.04.28.08.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 08:55:27 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id tp5so3386094ieb.41
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:55:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140428150034.GC7839@dhcp22.suse.cz>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
 <20140428150034.GC7839@dhcp22.suse.cz>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Mon, 28 Apr 2014 23:54:47 +0800
Message-ID: <CAHz2CGUObc=5g2TspQK-JX0GU9X3HJQ9s4t1ApfNR7qbdH71fw@mail.gmail.com>
Subject: Re: [PATCH RFC 1/2] mm/swap.c: split put_compound_page function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, khalid.aziz@oracle.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 28, 2014 at 11:00 PM, Michal Hocko <mhocko@suse.cz> wrote:
> This is a big change and really hard to review to be honest. Maybe a
> split up would make it easier to follow.

Ok,  actually it is quite simple, but the diff looks messy, I will try
to split up
this patch to several phases.

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
