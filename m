Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4366B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 08:09:29 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so39484420wgb.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 05:09:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si15960687wjx.25.2015.05.14.05.09.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 05:09:27 -0700 (PDT)
Date: Thu, 14 May 2015 14:09:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514120926.GF6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55536DC9.90200@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 13-05-15 18:29:13, Nikolay Borisov wrote:
[...]
> memcg_function_test   22  TFAIL  :  ltpapicmd.c:190: input=4095,
> limit_in_bytes=0
> memcg_function_test   23  TFAIL  :  ltpapicmd.c:190: input=4097,
> limit_in_bytes=4096
> memcg_function_test   24  TFAIL  :  ltpapicmd.c:190: input=1,
> limit_in_bytes=0

Before we go and fix these test cases. Do they make any sense at all?
Why should anybody even care that the limit is in page units? I do not
see anything like that mentioned in the documentation. Sure having
the limit in page size units makes a lot of sense from the
implementation POV but should userspace care? Would something break if
we change internals and allow also !page_aligned values? I have hard
time to imagine that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
