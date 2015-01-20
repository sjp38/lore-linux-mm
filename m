Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 172016B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 12:00:15 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so14885428pdb.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:00:14 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id k3si811057pdj.35.2015.01.20.09.00.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 09:00:13 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so46825719pad.3
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:00:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150120143644.GL25342@dhcp22.suse.cz>
References: <1421508107-29377-1-git-send-email-hannes@cmpxchg.org>
	<20150120133711.GI25342@dhcp22.suse.cz>
	<20150120143002.GB11181@phnom.home.cmpxchg.org>
	<20150120143644.GL25342@dhcp22.suse.cz>
Date: Tue, 20 Jan 2015 12:00:11 -0500
Message-ID: <CAOS58YNZFuSP6cKLAkYKkK+QUDxwngnKE5UGHmAL7n3PygraaQ@mail.gmail.com>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - "none"
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>

Hello,

On Tue, Jan 20, 2015 at 9:36 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 20-01-15 09:30:02, Johannes Weiner wrote:
> [...]
>> Another possibility would be "infinity",
>
> yes infinity definitely sounds much better to me.

FWIW, I prefer "max". It's shorter and clear enough. I don't think
there's anything ambiguous about "the memory max limit is at its
maximum". No need to introduce a different term.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
