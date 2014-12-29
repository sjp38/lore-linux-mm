Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 37DFD6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 12:03:16 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id z11so3400438lbi.34
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:03:15 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hg6si74273653wjc.36.2014.12.29.09.03.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Dec 2014 09:03:15 -0800 (PST)
Date: Mon, 29 Dec 2014 12:03:03 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH TRIVIAL] swap: remove unused
 mem_cgroup_uncharge_swapcache declaration
Message-ID: <20141229170303.GA12389@phnom.home.cmpxchg.org>
References: <1419854337-15161-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419854337-15161-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 29, 2014 at 02:58:57PM +0300, Vladimir Davydov wrote:
> The body of this function was removed by commit 0a31bc97c80c ("mm:
> memcontrol: rewrite uncharge API").
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
