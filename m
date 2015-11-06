Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A37D582F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 21:31:34 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so81956105pac.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 18:31:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gn6si12413190pbc.40.2015.11.05.18.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 18:31:33 -0800 (PST)
Date: Thu, 5 Nov 2015 18:31:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + memcg-fix-thresholds-for-32b-architectures-fix-fix.patch
 added to -mm tree
Message-Id: <20151105183132.0a5f874c7f5f69b3c2e53dd1@linux-foundation.org>
In-Reply-To: <20151104091804.GE29607@dhcp22.suse.cz>
References: <563943fb.IYtEMWL7tCGWBkSl%akpm@linux-foundation.org>
	<20151104091804.GE29607@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ben@decadent.org.uk, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Wed, 4 Nov 2015 10:18:04 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 03-11-15 15:32:11, Andrew Morton wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: memcg-fix-thresholds-for-32b-architectures-fix-fix
> > 
> > don't attempt to inline mem_cgroup_usage()
> > 
> > The compiler ignores the inline anwyay.  And __always_inlining it adds 600
> > bytes of goop to the .o file.
> 
> I am not sure you whether you want to fold this into the original patch
> but I would prefer this to be a separate one.

I'm going to drop this - it was already marked inline and gcc just
ignores the inline anyway so shrug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
