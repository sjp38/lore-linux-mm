Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 41CEC82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 04:52:11 -0500 (EST)
Received: by wmnn186 with SMTP id n186so37028634wmn.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 01:52:10 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id u12si13803965wjr.94.2015.11.06.01.52.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 01:52:10 -0800 (PST)
Received: by wmll128 with SMTP id l128so31010907wml.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 01:52:09 -0800 (PST)
Date: Fri, 6 Nov 2015 10:52:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + memcg-fix-thresholds-for-32b-architectures-fix-fix.patch added
 to -mm tree
Message-ID: <20151106095208.GD4390@dhcp22.suse.cz>
References: <563943fb.IYtEMWL7tCGWBkSl%akpm@linux-foundation.org>
 <20151104091804.GE29607@dhcp22.suse.cz>
 <20151105183132.0a5f874c7f5f69b3c2e53dd1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105183132.0a5f874c7f5f69b3c2e53dd1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ben@decadent.org.uk, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Thu 05-11-15 18:31:32, Andrew Morton wrote:
> On Wed, 4 Nov 2015 10:18:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 03-11-15 15:32:11, Andrew Morton wrote:
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Subject: memcg-fix-thresholds-for-32b-architectures-fix-fix
> > > 
> > > don't attempt to inline mem_cgroup_usage()
> > > 
> > > The compiler ignores the inline anwyay.  And __always_inlining it adds 600
> > > bytes of goop to the .o file.
> > 
> > I am not sure you whether you want to fold this into the original patch
> > but I would prefer this to be a separate one.
> 
> I'm going to drop this - it was already marked inline and gcc just
> ignores the inline anyway so shrug.

gcc version 5.2.1 20151010 (Debian 5.2.1-22)
$ size mm/memcontrol.o mm/memcontrol.o.before
   text    data     bss     dec     hex filename
  35535    7908      64   43507    a9f3 mm/memcontrol.o
  35762    7908      64   43734    aad6 mm/memcontrol.o.before

So it's only 227B but still. I think it is worth it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
