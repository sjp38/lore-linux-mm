Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7725D6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 19:50:52 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so4999353pab.16
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:50:52 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id yk1si12525462pbc.41.2014.06.16.16.50.50
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 16:50:51 -0700 (PDT)
Date: Tue, 17 Jun 2014 08:51:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
Message-ID: <20140616235117.GD18790@bbox>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
 <1402923474.3958.34.camel@debian>
 <20140616164237.5fcba7baaec83d509c9683e0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616164237.5fcba7baaec83d509c9683e0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Yucong <slaoub@gmail.com>, mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 16, 2014 at 04:42:37PM -0700, Andrew Morton wrote:
> On Mon, 16 Jun 2014 20:57:54 +0800 Chen Yucong <slaoub@gmail.com> wrote:
> 
> > On Mon, 2014-06-09 at 21:27 +0800, Chen Yucong wrote:
> > > Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
> > > original scan targets introduces extra 40 bytes on the stack. This patch
> > > is able to avoid this situation and the call to memcpy(). At the same time,
> > > it does not change the relative design idea.
> > > 
> > > ratio = original_nr_file / original_nr_anon;
> > > 
> > > If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
> > >  x = nr_file - ratio * nr_anon;
> > > 
> > > if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
> > >  x = nr_anon - nr_file / ratio;
> > > 
> > Hi Andrew Morton,
> > 
> > I think the patch
> >  
> > [PATCH]
> > mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec-fix.patch
> > 
> > which I committed should be discarded.
> 
> OK, thanks.
> 
> I assume you're referring to
> mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec.patch

True.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
