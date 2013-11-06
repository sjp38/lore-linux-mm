Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2102D6B00EC
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 11:35:22 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so2754871pbb.39
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 08:35:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.174])
        by mx.google.com with SMTP id yh6si17866050pab.34.2013.11.06.08.35.18
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 08:35:19 -0800 (PST)
Message-ID: <527A6F93.8070606@sr71.net>
Date: Wed, 06 Nov 2013 08:34:27 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: thp: give transparent hugepage code a separate
 copy_page
References: <20131028221618.4078637F@viggo.jf.intel.com>	<20131028221620.042323B3@viggo.jf.intel.com> <CAJd=RBAFgn=3GvEEdHDARpw_h+6SbYE_35D5QJX7C60cVd4tmA@mail.gmail.com>
In-Reply-To: <CAJd=RBAFgn=3GvEEdHDARpw_h+6SbYE_35D5QJX7C60cVd4tmA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On 11/06/2013 05:46 AM, Hillf Danton wrote:
> On Tue, Oct 29, 2013 at 6:16 AM, Dave Hansen <dave@sr71.net> wrote:
>> +
>> +void copy_high_order_page(struct page *newpage,
>> +                         struct page *oldpage,
>> +                         int order)
>> +{
>> +       int i;
>> +
>> +       might_sleep();
>> +       for (i = 0; i < (1<<order); i++) {
>> +               cond_resched();
>> +               copy_highpage(newpage + i, oldpage + i);
>> +       }
>> +}
> 
> Can we make no  use of might_sleep here with cond_resched in loop?

I'm not sure what you're saying.

Are you pointing out that cond_resched() actually calls might_sleep() so
the might_sleep() is redundant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
