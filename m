Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 32FC7900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 13:28:16 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id n4so2380713qaq.12
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 10:28:16 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com. [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id v5si2802272qat.109.2015.02.04.10.28.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 10:28:15 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id n8so2402360qaq.6
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 10:28:15 -0800 (PST)
Date: Wed, 4 Feb 2015 13:28:11 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150204182811.GC18858@htj.dyndns.org>
References: <20150130044324.GA25699@htj.dyndns.org>
 <xr93h9v8yfrv.fsf@gthelen.mtv.corp.google.com>
 <20150130062737.GB25699@htj.dyndns.org>
 <20150130160722.GA26111@htj.dyndns.org>
 <54CFCF74.6090400@yandex-team.ru>
 <20150202194608.GA8169@htj.dyndns.org>
 <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
 <54D1F924.5000001@yandex-team.ru>
 <20150204171512.GB18858@htj.dyndns.org>
 <54D25DBD.5080009@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54D25DBD.5080009@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>

On Wed, Feb 04, 2015 at 08:58:21PM +0300, Konstantin Khlebnikov wrote:
> >>Generally incidental sharing could be handled as temporary sharing:
> >>default policy (if inode isn't pinned to memory cgroup) after some
> >>time should detect that inode is no longer shared and migrate it into
> >>original cgroup. Of course task could provide hit: O_NO_MOVEMEM or
> >>even while memory cgroup where it runs could be marked as "scanner"
> >>which shouldn't disturb memory classification.
> >
> >Ditto for annotating each file individually.  Let's please try to stay
> >away from things like that.  That's mostly a cop-out which is unlikely
> >to actually benefit the majority of users.
> 
> Process which scans all files once isn't so rare use case.
> Linux still cannot handle this pattern sometimes.

Yeah, sure, tagging usages with m/fadvise's is fine.  We can just look
at the policy and ignore them for the purpose of determining who's
using the inode, but let's stay away from tagging the files on
filesystem if at all possible.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
