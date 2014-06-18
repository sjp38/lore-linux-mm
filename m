Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA7B6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 05:11:42 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so549795pbb.11
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:11:41 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id y3si1488183pbw.183.2014.06.18.02.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 02:11:41 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so540536pad.38
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 02:11:40 -0700 (PDT)
Message-ID: <1403082532.9368.4.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
From: Chen Yucong <slaoub@gmail.com>
Date: Wed, 18 Jun 2014 17:08:52 +0800
In-Reply-To: <53A15544.2010505@redhat.com>
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
	 <53A15544.2010505@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-06-18 at 11:00 +0200, Jerome Marchand wrote:
> >               if (!nr_file || !nr_anon)
> >                       break;
> >  
> > -             if (nr_file > nr_anon) {
> > -                     unsigned long scan_target =
> targets[LRU_INACTIVE_ANON] +
> >
> -                                             targets[LRU_ACTIVE_ANON]
> + 1;
> > +             file_percent = nr_file * 100 / file_target;
> > +             anon_percent = nr_anon * 100 / anon_target;
> 
> Here it could happen.
> 
> 
The snippet 
	...
               if (!nr_file || !nr_anon)
                      break;
        ...
 can help us to filter the situation which you have described. It comes
from Mel's patch that is called:

mm: vmscan: use proportional scanning during direct reclaim and full
scan at DEF_PRIORITY

thx!
cyc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
