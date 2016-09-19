Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96C286B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 05:42:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so57965670wmf.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 02:42:27 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v205si17585475wmg.91.2016.09.19.02.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 02:42:26 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l132so12738148wmf.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 02:42:26 -0700 (PDT)
Date: Mon, 19 Sep 2016 11:42:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] scripts: Include postprocessing script for memory
 allocation tracing
Message-ID: <20160919094224.GH10785@dhcp22.suse.cz>
References: <20160911222411.GA2854@janani-Inspiron-3521>
 <20160912121635.GL14524@dhcp22.suse.cz>
 <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org

On Tue 13-09-16 14:04:49, Janani Ravichandran wrote:
> 
> > On Sep 12, 2016, at 8:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > Hi,
> 
> Hello Michal,
> 
> > I am sorry I didn't follow up on the previous submission.
> 
> Thata??s alright :)
> 
> > I find this
> > _really_ helpful. It is great that you could build on top of existing
> > tracepoints but one thing is not entirely clear to me. Without a begin
> > marker in __alloc_pages_nodemask we cannot really tell how long the
> > whole allocation took, which would be extremely useful. Or do you use
> > any graph tracer tricks to deduce that?
> 
> Ia??m using the function graph tracer to see how long __alloc_pages_nodemask()
> took.

How can you map the function graph tracer to a specif context? Let's say
I would like to know why a particular allocation took so long. Would
that be possible?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
