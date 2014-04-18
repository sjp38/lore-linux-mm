Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 790666B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:37:16 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id ec20so1626947lab.1
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:37:15 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y6si19462303lal.194.2014.04.18.11.37.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 11:37:14 -0700 (PDT)
Message-ID: <535170D5.9090006@parallels.com>
Date: Fri, 18 Apr 2014 22:37:09 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg with kmem limit doesn't recover after disk i/o causes limit
 to be hit
References: <20140416154650.GA3034@alpha.arachsys.com> <20140418155939.GE4523@dhcp22.suse.cz> <5351679F.5040908@parallels.com> <20140418182033.GA22235@dhcp22.suse.cz>
In-Reply-To: <20140418182033.GA22235@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Richard Davies <richard@arachsys.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

18.04.2014 22:20, Michal Hocko:
> On Fri 18-04-14 21:57:51, Vladimir Davydov wrote:
>> In short, kmem limiting for memory cgroups is currently broken. Do not
>> use it. We are working on making it usable though.
> 
> Maybe we should make this explicit in both
> Documentation/cgroups/memory.txt and config MEMCG_KMEM help text.

Yeah, definitely. I'll send the patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
