Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DB45E6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 17:07:17 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so86453442wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 14:07:17 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id x13si20671622wjw.168.2016.02.19.14.07.16
        for <linux-mm@kvack.org>;
        Fri, 19 Feb 2016 14:07:16 -0800 (PST)
Date: Fri, 19 Feb 2016 14:07:01 -0800
From: Andres Freund <andres@anarazel.de>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160219220701.zjmonn3mj4sgmqcs@alap3.anarazel.de>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
 <20160212202405.GA32367@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212202405.GA32367@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hi Johannes,

On 2016-02-12 15:24:05 -0500, Johannes Weiner wrote:
> I've updated the patch to work with cgroups.

Are tests of this patch, in contrast to the earlier version, necessary?
If so, what's this patch based upon? Because it doesn't seem to apply
cleanly to any tree I know about. Not very hard to resolve conflicts,
mind you, but ...

- Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
