Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id E764F6B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 15:30:05 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so30767516ykd.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 12:30:05 -0700 (PDT)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id x138si2067896ywd.152.2015.09.04.12.30.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 12:30:04 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so30766359ykd.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 12:30:03 -0700 (PDT)
Date: Fri, 4 Sep 2015 15:30:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150904193000.GG25329@mtj.duckdns.org>
References: <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
 <20150902093039.GA30160@esperanza>
 <20150903163243.GD10394@mtj.duckdns.org>
 <20150904111550.GB13699@esperanza>
 <20150904154448.GA25329@mtj.duckdns.org>
 <20150904182110.GE13699@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904182110.GE13699@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Vladimir.

On Fri, Sep 04, 2015 at 09:21:11PM +0300, Vladimir Davydov wrote:
> Now I think task_work reclaim initially proposed by Tejun would be a
> much better fix.

Cool, I'll update the patch.

> I'm terribly sorry for being so annoying and stubborn and want to thank
> you for all your feedback!

Heh, I'm not all that confident about my position.  A lot of it could
be from lack of experience and failing to see the gradients.  Please
keep me in check if I get lost.

Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
