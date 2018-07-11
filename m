Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3D36B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:21:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c20-v6so9793575eds.21
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:21:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t9-v6si1180898edh.240.2018.07.11.03.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 03:21:41 -0700 (PDT)
Date: Wed, 11 Jul 2018 12:21:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180711102139.GG20050@dhcp22.suse.cz>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Tue 10-07-18 12:09:17, Waiman Long wrote:
> On 07/10/2018 10:27 AM, Michal Hocko wrote:
> > On Mon 09-07-18 12:01:04, Waiman Long wrote:
> >> On 07/09/2018 04:19 AM, Michal Hocko wrote:
[...]
> >>> percentage has turned out to be a really wrong unit for many tunables
> >>> over time. Even 1% can be just too much on really large machines.
> >> Yes, that is true. Do you have any suggestion of what kind of unit
> >> should be used? I can scale down the unit to 0.1% of the system memory.
> >> Alternatively, one unit can be 10k/cpu thread, so a 20-thread system
> >> corresponds to 200k, etc.
> > I simply think this is a strange user interface. How much is a
> > reasonable number? How can any admin figure that out?
> 
> Without the optional enforcement, the limit is essentially just a
> notification mechanism where the system signals that there is something
> wrong going on and the system administrator need to take a look. So it
> is perfectly OK if the limit is sufficiently high that normally we won't
> need to use that many negative dentries. The goal is to prevent negative
> dentries from consuming a significant portion of the system memory.

So again. How do you tell the right number?

> I am going to reduce the granularity of each unit to 1/1000 of the total
> system memory so that for large system with TB of memory, a smaller
> amount of memory can be specified.

It is just a matter of time for this to be too coarse as well.
-- 
Michal Hocko
SUSE Labs
