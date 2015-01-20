Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id EBA8B6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:30:08 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so25943379wib.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:30:08 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v4si33248513wja.154.2015.01.20.06.30.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 06:30:08 -0800 (PST)
Date: Tue, 20 Jan 2015 09:30:02 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - "none"
Message-ID: <20150120143002.GB11181@phnom.home.cmpxchg.org>
References: <1421508107-29377-1-git-send-email-hannes@cmpxchg.org>
 <20150120133711.GI25342@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120133711.GI25342@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 20, 2015 at 02:37:11PM +0100, Michal Hocko wrote:
> On Sat 17-01-15 10:21:47, Johannes Weiner wrote:
> > The "none" name for the low-boundary 0 and the high-boundary maximum
> > value can be confusing.
> > 
> > Just leave the low boundary at 0, and give the highest-possible
> > boundary value the name "max" that means the same for controls.
> 
> max might be confusing as well because it matches with the knob name.
> max_resource or max_memory sounds better to me.

These names are appalling in the same way that memory.limit_in_bytes
is.  They are too long, while their information density is low.  They
make you type out the unit that should be painfully obvious to anybody
doing the typing.  And they still overlap with the knob name!

$ cat memory.max
max_memory

Really?

Another possibility would be "infinity", but tbh I think "max" is just
fine.  It's descriptive, the potential for confusion is low and easily
eliminated with documentation, and it's short and easy to type.

> Btw. I would separate page_counter_memparse change out and
> replace the original 'mm: page_counter: pull "-1" handling out of
> page_counter_memparse()' by it.

Yeah, that would probably make sense, but we can't do it incrementally
anymore.  Andrew, want me to resend these two patches with all fixes
incorporated?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
