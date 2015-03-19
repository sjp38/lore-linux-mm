Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 856A96B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 06:41:15 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so59238720pab.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:41:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ff2si2104073pab.111.2015.03.19.03.41.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 03:41:14 -0700 (PDT)
Date: Thu, 19 Mar 2015 13:41:03 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/3] mm: idle memory tracking
Message-ID: <20150319104103.GA12162@esperanza>
References: <cover.1426706637.git.vdavydov@parallels.com>
 <0b70e70137aa5232cce44a69c0b5e320f2745f7d.1426706637.git.vdavydov@parallels.com>
 <20150319101205.GC27066@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150319101205.GC27066@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 19, 2015 at 01:12:05PM +0300, Cyrill Gorcunov wrote:
> On Wed, Mar 18, 2015 at 11:44:36PM +0300, Vladimir Davydov wrote:
> > +static void set_mem_idle(void)
> > +{
> > +	int nid;
> > +
> > +	for_each_online_node(nid)
> > +		set_mem_idle_node(nid);
> > +}
> 
> Vladimir, might we need get_online_mems/put_online_mems here,
> or if node gets offline this wont be a problem? (Asking
> because i don't know).

I only need to dereference page structs corresponding to the node here,
and page structs are not freed when the node gets offline AFAICS, so I
guess it must be safe.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
