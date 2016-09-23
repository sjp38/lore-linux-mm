Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9BA528024D
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 17:30:32 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g18so8999442ywb.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 14:30:32 -0700 (PDT)
Received: from mail-yw0-x22d.google.com (mail-yw0-x22d.google.com. [2607:f8b0:4002:c05::22d])
        by mx.google.com with ESMTPS id y78si3502672ywd.375.2016.09.23.14.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 14:30:32 -0700 (PDT)
Received: by mail-yw0-x22d.google.com with SMTP id t67so123709737ywg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 14:30:32 -0700 (PDT)
Date: Fri, 23 Sep 2016 17:30:30 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/percpu.c: correct max_distance calculation for
 pcpu_embed_first_chunk()
Message-ID: <20160923213030.GG31387@htj.duckdns.org>
References: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
 <20160923192351.GE31387@htj.duckdns.org>
 <39277252-5bf4-b355-c076-8059e693f4aa@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39277252-5bf4-b355-c076-8059e693f4aa@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux.com

Hello,

On Sat, Sep 24, 2016 at 05:16:56AM +0800, zijun_hu wrote:
> On 2016/9/24 3:23, Tejun Heo wrote:
> > On Sat, Sep 24, 2016 at 02:20:24AM +0800, zijun_hu wrote:
> >> From: zijun_hu <zijun_hu@htc.com>
> >>
> >> correct max_distance from (base of the highest group + ai->unit_size)
> >> to (base of the highest group + the group size)
> >>
> >> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> > 
> > Nacked-by: Tejun Heo <tj@kernel.org>
> > 
> > Thanks.
> >
> frankly, the current max_distance is error, doesn't represents the ranges spanned by
> areas owned by the groups

I think you're right but can you please update the patch description
so that it explains what the bug and the implications are and how the
patch fixes the bug.  Also, please make sure that all changes made by
the patch are explained in the description - e.g. why the type of
@max_distance is changed from size_t to ulong.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
