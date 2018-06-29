Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8CE16B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 03:31:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k5-v6so2724744edq.9
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 00:31:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4-v6si4254587edd.398.2018.06.29.00.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 00:31:50 -0700 (PDT)
Date: Fri, 29 Jun 2018 09:31:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hugetlb: yield when prepping struct pages
Message-ID: <20180629073146.GB13860@dhcp22.suse.cz>
References: <20180627214447.260804-1-cannonmatthews@google.com>
 <20180628112139.GC32348@dhcp22.suse.cz>
 <CAJfu=Uc8zkN1fc73_UtiREW061xakrnMNP27oV5i3AreP1XS+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfu=Uc8zkN1fc73_UtiREW061xakrnMNP27oV5i3AreP1XS+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: mike.kravetz@oracle.com, akpm@linux-foundation.org, nyc@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Peter Feiner <pfeiner@google.com>, Greg Thelen <gthelen@google.com>

On Thu 28-06-18 15:16:46, Cannon Matthews wrote:
> Thanks for the quick turnaround.
> 
> Good to know about the how the 2M code path differs, I have been
> trying to trace through some of this and it's easy to get lost between
> which applies to which size.

Yeah, GB hugetlb pages implementation has been hacked into the existing
hugetlb code in a quite ugly way. We have done some cleanups since then
but there is still a lot of room for improvements.
-- 
Michal Hocko
SUSE Labs
