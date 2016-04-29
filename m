Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C477C6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:21:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so14433985wme.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:21:47 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id w8si16298985wjz.65.2016.04.29.02.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 02:21:46 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id a17so26019265wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:21:46 -0700 (PDT)
Date: Fri, 29 Apr 2016 11:21:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Use existing helper to convert "on/off" to boolean
Message-ID: <20160429092145.GC21977@dhcp22.suse.cz>
References: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
 <20160429080430.GA21977@dhcp22.suse.cz>
 <20160429090742.GA16688@dhcp-128-44.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429090742.GA16688@dhcp-128-44.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minfei Huang <mnghuan@gmail.com>
Cc: akpm@linux-foundation.org, labbott@fedoraproject.org, rjw@rjwysocki.net, mgorman@techsingularity.net, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, alexander.h.duyck@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 29-04-16 17:07:42, Minfei Huang wrote:
> On 04/29/16 at 10:04P, Michal Hocko wrote:
> > On Fri 29-04-16 13:47:04, Minfei Huang wrote:
> > > It's more convenient to use existing function helper to convert string
> > > "on/off" to boolean.
> > 
> > But kstrtobool in linux-next only does "This routine returns 0 iff the
> > first character is one of 'Yy1Nn0'" so it doesn't know about on/off.
> > Or am I missing anything?
> 
> Hi, Michal.
> 
> Thanks for your reply.
> 
> Following is the kstrtobool comment from linus tree, which has explained
> that this function can parse "on"/"off" string. Also Kees Cook has
> posted such patch to fix this issue as well. So I think it's safe to fix
> it.

OK, I was looking at wrong tree and missed a81a5a17d44b ("lib: add
"on"/"off" support to kstrtobool")

Sorry about the confusion. Feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
