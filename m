Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id C6AB16B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:40:44 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id t10so433397eei.26
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:40:44 -0800 (PST)
Received: from mail-ee0-x22d.google.com (mail-ee0-x22d.google.com [2a00:1450:4013:c00::22d])
        by mx.google.com with ESMTPS id b4si2667528eew.250.2014.02.19.11.40.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 11:40:43 -0800 (PST)
Received: by mail-ee0-f45.google.com with SMTP id b15so443582eek.18
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:40:42 -0800 (PST)
Date: Wed, 19 Feb 2014 20:40:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] mm: exclude memory less nodes from zone_reclaim
Message-ID: <20140219194039.GA5825@dhcp22.suse.cz>
References: <20140219082313.GB14783@dhcp22.suse.cz>
 <1392829383-4125-1-git-send-email-mhocko@suse.cz>
 <20140219171628.GE27108@linux.vnet.ibm.com>
 <20140219173259.GA5041@dhcp22.suse.cz>
 <20140219174940.GF27108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219174940.GF27108@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 19-02-14 09:49:41, Nishanth Aravamudan wrote:
> On 19.02.2014 [18:32:59 +0100], Michal Hocko wrote:
> > On Wed 19-02-14 09:16:28, Nishanth Aravamudan wrote:
[...]
> > > I don't think this will work, because what sets N_HIGH_MEMORY (and
> > > shouldn't it be N_MEMORY?)
> > 
> > This should be the same thing AFAIU.
> 
> I don't think they are guaranteed to be? And, in any case, semantically,
> we care if a node has MEMORY, not if it has HIGH_MEMORY?

I don't know. The whole MEMORY vs HIGH_MEMORY thing is really
confusing. But my understanding was that HIGH_MEMORY is superset of the
other one. But now that I look at the code again it seems that N_MEMORY
is the right thing to use here. I will repost the patch tomorrow if
other parts are good.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
