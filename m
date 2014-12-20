Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBB46B006E
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:23:13 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so2167056pad.38
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 16:23:13 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id fk2si12219927pab.155.2014.12.19.16.23.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 16:23:12 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2132830pab.26
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 16:23:11 -0800 (PST)
Date: Sat, 20 Dec 2014 09:23:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-ID: <20141220002303.GD11975@blaptop>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
 <20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
 <20141219233937.GA11975@blaptop>
 <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
 <20141219235852.GB11975@blaptop>
 <20141219160648.5cea8a6b0c764caa6100a585@linux-foundation.org>
 <20141220001043.GC11975@blaptop>
 <20141219161756.bcf7421acb4bc7a286c1afa3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141219161756.bcf7421acb4bc7a286c1afa3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 19, 2014 at 04:17:56PM -0800, Andrew Morton wrote:
> On Sat, 20 Dec 2014 09:10:43 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > > It involves rehashing a lengthy argument with Greg.
> > 
> > Okay. Then, Ganesh,
> > please add warn message about duplicaed name possibility althoug
> > it's unlikely as it is.
> 
> Oh, getting EEXIST is easy with this patch.  Just create and destroy a
> pool 2^32 times and the counter wraps ;) It's hardly a serious issue
> for a debugging patch.

I meant that I wanted to change from index to name passed from caller like this

zram:
	zs_create_pool(GFP_NOIO | __GFP_HIGHMEM, zram->disk->first_minor);

So, duplication should be rare. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
