Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4E64F82F97
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 17:19:28 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l126so161746491wml.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 14:19:28 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v188si30572394wmg.123.2015.12.23.14.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 14:19:27 -0800 (PST)
Date: Wed, 23 Dec 2015 17:19:06 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: memcontrol: fix possible memcg leak due to
 interrupted reclaim
Message-ID: <20151223221906.GB12165@cmpxchg.org>
References: <1450182697-11049-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450182697-11049-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I think we can fold the following in there as well:
