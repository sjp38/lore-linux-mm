Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7B0F6B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:40:28 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l10-v6so9481111qth.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:40:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t87-v6si2868936qki.107.2018.06.29.07.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 07:40:27 -0700 (PDT)
Subject: Re: [PATCH v2] kvm, mm: account shadow page tables to kmemcg
References: <20180629140224.205849-1-shakeelb@google.com>
 <20180629143044.GF5963@dhcp22.suse.cz>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <efdb8e40-742e-d120-6589-96b4fdf83cb9@redhat.com>
Date: Fri, 29 Jun 2018 16:40:23 +0200
MIME-Version: 1.0
In-Reply-To: <20180629143044.GF5963@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, stable@vger.kernel.org

On 29/06/2018 16:30, Michal Hocko wrote:
> I am not familiar wtih kvm to judge but if we are going to account this
> memory we will probably want to let oom_badness know how much memory
> to account to a specific process. Is this something that we can do?
> We will probably need a new MM_KERNEL rss_stat stat for that purpose.
> 
> Just to make it clear. I am not opposing to this patch but considering
> that shadow page tables might consume a lot of memory it would be good
> to know who is responsible for it from the OOM perspective. Something to
> solve on top of this.

The amount of memory is generally proportional to the size of the
virtual machine memory, which is reflected directly into RSS.  Because
KVM processes are usually huge, and will probably dwarf everything else
in the system (except firefox and chromium of course :)), the general
order of magnitude of the oom_badness should be okay.

> I would also love to see a note how this memory is bound to the owner
> life time in the changelog. That would make the review much more easier.

--verbose for people that aren't well versed in linux mm, please...

Paolo
