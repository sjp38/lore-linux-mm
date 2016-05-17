Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55F9E6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 16:34:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so14802963lfd.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:34:24 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 142si6313886wmn.98.2016.05.17.13.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 13:34:22 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id g17so1085666wme.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:34:22 -0700 (PDT)
Date: Tue, 17 May 2016 22:34:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160517203420.GG12220@dhcp22.suse.cz>
References: <20160516152522.GA19120@redhat.com>
 <20160516152546.GA19129@redhat.com>
 <20160516172254.GA8595@redhat.com>
 <20160517153302.GE14446@dhcp22.suse.cz>
 <20160517163044.GA31867@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517163044.GA31867@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 17-05-16 18:30:44, Oleg Nesterov wrote:
> On 05/17, Michal Hocko wrote:
> >
> > On Mon 16-05-16 19:22:54, Oleg Nesterov wrote:
> >
> > > The patch adds the new trivial helper, mmget_not_zero(), it can have more users.
> >
> > Is this really helpful?
> 
> Well, this is subjective of course, but I think the code looks a bit better this
> way. uprobes, fs/proc and more can use this helper too.
> 
> And in fact the initial version of this patch did atomic_inc_not_zero(mm->users) by
> hand, then it was suggested to add a helper.

I would prefer a more descriptive name (something like mmget_alive) but
as you say this is highly subjective and nothing that should delay this
fix.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
