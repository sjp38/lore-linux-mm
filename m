Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFF976B026B
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:43:11 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d7-v6so9583554qth.21
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:43:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r2-v6si5983434qvb.28.2018.06.29.08.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:43:10 -0700 (PDT)
Subject: Re: [PATCH v2] kvm, mm: account shadow page tables to kmemcg
References: <20180629140224.205849-1-shakeelb@google.com>
 <20180629143044.GF5963@dhcp22.suse.cz>
 <efdb8e40-742e-d120-6589-96b4fdf83cb9@redhat.com>
 <20180629145513.GG5963@dhcp22.suse.cz>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <1595a887-fac8-f8ea-ecd3-4ba0783ef88b@redhat.com>
Date: Fri, 29 Jun 2018 17:43:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180629145513.GG5963@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Peter Feiner <pfeiner@google.com>, stable@vger.kernel.org

On 29/06/2018 16:55, Michal Hocko wrote:
>>> I would also love to see a note how this memory is bound to the owner
>>> life time in the changelog. That would make the review much more easier.
>> --verbose for people that aren't well versed in linux mm, please...
> Well, if the memory accounted to the memcg hits the hard limit and there
> is no way to reclaim anything to reduce the charged memory then we have
> to kill something. Hopefully the memory hog. If that one dies it would
> be great it releases its charges along the way. My remark was just to
> explain how that would happen for this specific type of memory. Bound to
> a file, has its own tear down etc. Basically make life of reviewers
> easier to understand the lifetime of charged objects without digging
> deep into the specific subsystem.

Oh I see.  Yes, it's all freed when the VM file descriptor (which you
get with a ioctl on /dev/kvm) is closed.

Thanks,

Paolo
