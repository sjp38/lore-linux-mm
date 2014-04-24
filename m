Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id DF7D76B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:59:39 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so837767wib.17
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:59:39 -0700 (PDT)
Received: from alpha.arachsys.com (alpha.arachsys.com. [2001:9d8:200a:0:9f:9fff:fe90:dbe3])
        by mx.google.com with ESMTPS id w6si9080330wie.22.2014.04.24.03.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 03:59:38 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:59:33 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Re: Kernel crash triggered by dd to file with memcg, worst on btrfs
Message-ID: <20140424105933.GD32011@alpha.arachsys.com>
References: <20140416174210.GA11486@alpha.arachsys.com>
 <20140423215852.GA6651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140423215852.GA6651@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

Michal Hocko wrote:
> Richard Davies wrote:
> > I have a test case in which I can often crash an entire machine by running
> > dd to a file with a memcg with relatively generous limits. This is
> > simplified from real world problems with heavy disk i/o inside containers.
...
> > [I have also just reported a different but similar bug with untar in a memcg
> > http://marc.info/?l=linux-mm&m=139766321822891 That one is not btrfs-linked]
...
> Does this happen even if no kmem limit is specified?

No, it only happens with a kmem limit.

So it is due to the kmem limiting being broken, as we discussed in the other
"untar" thread lined above.

> The kmem limit would explain allocation failures for ext3 logged below
> but I would be interested about the "Thread overran stack, or stack
> corrupted" message reported for btrfs. The stack doesn't seem very deep
> there. I would expect some issues in the writeback path during the limit
> reclaim but this looks quite innocent. Rulling out kmem accounting would
> be a good first step though . (I am keepinng the full email for Vladimir)

The btrfs problems only occur with a kmem limit. So this is also kmem-linked
even if that is surprising.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
