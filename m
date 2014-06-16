Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 783C26B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 19:52:40 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so5030336pac.39
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:52:40 -0700 (PDT)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id yu2si15264275pac.156.2014.06.16.16.52.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 16:52:39 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id rp16so4985314pbb.23
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:52:39 -0700 (PDT)
Message-ID: <1402962603.3958.36.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
From: Chen Yucong <slaoub@gmail.com>
Date: Tue, 17 Jun 2014 07:50:03 +0800
In-Reply-To: <20140616164237.5fcba7baaec83d509c9683e0@linux-foundation.org>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
	 <1402923474.3958.34.camel@debian>
	 <20140616164237.5fcba7baaec83d509c9683e0@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-06-16 at 16:42 -0700, Andrew Morton wrote:
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
> - I don't think a -fix.patch existed?

Yes. the patch that should be discarded is 
mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec.patch

thx!
cyc


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
