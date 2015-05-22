Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1A4829C8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 14:23:53 -0400 (EDT)
Received: by qkx62 with SMTP id 62so18305331qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 11:23:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 35si3191826qgt.121.2015.05.22.11.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 11:23:52 -0700 (PDT)
Date: Fri, 22 May 2015 20:22:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/3] memcg: mm_update_next_owner() cleanups
Message-ID: <20150522182251.GE26770@redhat.com>
References: <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz> <20150520175302.GA7287@redhat.com> <20150520202221.GD14256@dhcp22.suse.cz> <20150521192716.GA21304@redhat.com> <20150522093639.GE5109@dhcp22.suse.cz> <20150522162900.GA8955@redhat.com> <20150522182054.GA26770@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522182054.GA26770@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On 05/22, Oleg Nesterov wrote:
>
> On 05/22, Oleg Nesterov wrote:
> >
> > Oh. I think mm_update_next_owner() needs some cleanups. Perhaps I'll send
> > the patch today.
>
> At least something like this...
>
> Although I still think we can just remove this code. Plus this series
> was only compile tested, so please feel free to ignore.

Heh ;) sorry for noise.

Yes, please ignore, I just notice another email from you. Will reply
in a minute.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
