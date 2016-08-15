Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB476B0266
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:50:42 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m184so32983683qkb.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:50:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d187si7978628lfe.91.2016.08.15.08.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:50:41 -0700 (PDT)
Date: Mon, 15 Aug 2016 11:47:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH stable-4.4 0/3 v2] backport memcg id patches
Message-ID: <20160815154705.GA6283@cmpxchg.org>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 15, 2016 at 05:06:43PM +0200, Michal Hocko wrote:
> This is the second version which addresses review feedback from Johannes [1]

With the final 1/3, this looks good to me. Thanks for doing the
backport, Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
