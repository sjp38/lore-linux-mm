Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C45B66B00CA
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 10:17:11 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id y10so2858048wgg.32
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 07:17:11 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pg7si6906161wjb.56.2014.06.13.07.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 07:17:09 -0700 (PDT)
Date: Fri, 13 Jun 2014 10:17:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RESEND PATCH v2] mm/vmscan.c: wrap five parameters into
 writeback_stats for reducing the stack consumption
Message-ID: <20140613141700.GO2878@cmpxchg.org>
References: <1402639088-4845-1-git-send-email-slaoub@gmail.com>
 <1402667259.6072.20.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402667259.6072.20.camel@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 13, 2014 at 09:47:39PM +0800, Chen Yucong wrote:
> Hi all,
> 
> On Fri, 2014-06-13 at 13:58 +0800, Chen Yucong wrote:
> > shrink_page_list() has too many arguments that have already reached ten.
> > Some of those arguments and temporary variables introduces extra 80 bytes
> > on the stack. This patch wraps five parameters into writeback_stats and removes
> > some temporary variables, thus making the relative functions to consume fewer
> > stack space.
> > 
> I this message, I have renamed shrink_result to writeback_stats
> according to Johannes Weiner's reply. Think carefully, this change is
> too hasty. Although it now just contains statistics on the writeback
> states of the scanned pages, it may also be used for gathering other
> information at some point in the future. So I think shrink_result is a
> little bit better!

Then we can always rename it "at some point in the future", the name
is not set in stone.  At this time, it only contains writeback stats,
and I think it should be named accordingly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
