Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 927C06B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:27:14 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so12799219pdb.10
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 04:27:14 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fa6si8914758pab.53.2014.09.26.04.27.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 04:27:13 -0700 (PDT)
Date: Fri, 26 Sep 2014 15:27:04 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 3/3] kernel: res_counter: remove the unused API
Message-ID: <20140926112704.GG29445@esperanza>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1411573390-9601-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 11:43:10AM -0400, Johannes Weiner wrote:
> All memory accounting and limiting has been switched over to the
> lockless page counters.  Bye, res_counter!
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
