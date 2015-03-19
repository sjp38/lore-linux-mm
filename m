Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id D2F5C6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 06:45:27 -0400 (EDT)
Received: by labjg1 with SMTP id jg1so58563934lab.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:45:27 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id l4si741010lbg.1.2015.03.19.03.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 03:45:26 -0700 (PDT)
Received: by lagg8 with SMTP id g8so58604559lag.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 03:45:25 -0700 (PDT)
Date: Thu, 19 Mar 2015 13:45:24 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/3] mm: idle memory tracking
Message-ID: <20150319104524.GD27066@moon>
References: <cover.1426706637.git.vdavydov@parallels.com>
 <0b70e70137aa5232cce44a69c0b5e320f2745f7d.1426706637.git.vdavydov@parallels.com>
 <20150319101205.GC27066@moon>
 <20150319104103.GA12162@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150319104103.GA12162@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 19, 2015 at 01:41:03PM +0300, Vladimir Davydov wrote:
> > 
> > Vladimir, might we need get_online_mems/put_online_mems here,
> > or if node gets offline this wont be a problem? (Asking
> > because i don't know).
> 
> I only need to dereference page structs corresponding to the node here,
> and page structs are not freed when the node gets offline AFAICS, so I
> guess it must be safe.

OK, thanks for info!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
