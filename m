Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF4E6B03F1
	for <linux-mm@kvack.org>; Tue,  9 May 2017 05:46:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p134so14406362wmg.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 02:46:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u197si337033wmf.141.2017.05.09.02.46.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 02:46:09 -0700 (PDT)
Date: Tue, 9 May 2017 11:46:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
Message-ID: <20170509094607.GG6481@dhcp22.suse.cz>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
 <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
 <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
 <20170426201126.GA32407@dhcp22.suse.cz>
 <40f72efa-3928-b3c6-acca-0740f1a15ba4@oracle.com>
 <429c8506-c498-0599-4258-7bac947fe29c@oracle.com>
 <20170505133029.GC31461@dhcp22.suse.cz>
 <e7c61dec-9d57-957b-7ff5-8247fa51eafb@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7c61dec-9d57-957b-7ff5-8247fa51eafb@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Fri 05-05-17 11:33:36, Pasha Tatashin wrote:
> 
> 
> On 05/05/2017 09:30 AM, Michal Hocko wrote:
> >On Thu 04-05-17 14:28:51, Pasha Tatashin wrote:
> >>BTW, I am OK with your patch on top of this "Adaptive hash table" patch, but
> >>I do not know what high_limit should be from where HASH_ADAPT will kick in.
> >>128M sound reasonable to you?
> >
> >For simplicity I would just use it unconditionally when no high_limit is
> >set. What would be the problem with that?
> 
> Sure, that sounds good.
> 
>  If you look at current users
> >(and there no new users emerging too often) then most of them just want
> >_some_ scaling. The original one obviously doesn't scale with large
> >machines. Are you OK to fold my change to your patch or you want me to
> >send a separate patch? AFAIK Andrew hasn't posted this patch to Linus
> >yet.
> >
> 
> I would like a separate patch because mine has soaked in mm tree for a while
> now.

OK, Andrew tends to fold follow up fixes in his mm tree. But anyway, as
you prefer to have this in a separate patch. Could you add this on top
Andrew? I believe mnt hash tables need a _reasonable_ upper bound but
that is for a separate patch I believe.
--- 
