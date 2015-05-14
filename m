Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 72EDE6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 11:28:23 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so98948191wic.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 08:28:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si14920567wix.98.2015.05.14.08.28.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 08:28:21 -0700 (PDT)
Date: Thu, 14 May 2015 17:27:49 +0200
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514152749.GF12884@rei>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514103148.GA5066@rei.suse.de>
 <20150514115641.GE6799@dhcp22.suse.cz>
 <20150514120142.GG5066@rei.suse.de>
 <20150514121248.GG6799@dhcp22.suse.cz>
 <20150514123816.GC6993@rei>
 <20150514143039.GI6799@dhcp22.suse.cz>
 <20150514144420.GA12884@rei>
 <20150514144949.GJ6799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514144949.GJ6799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

Hi!
> testcase_29 and testcase_30 are no longer testing anything because
> the kernel allows to use force_empty even for memcgs with active
> tasks since f61c42a7d911 ("memcg: remove tasks/children test from
> mem_cgroup_force_empty()) kernel commit.
> 
> If we really want to test this functionality then just expect the
> success for regular mmap and expect the failure when the charged
> memory is mlocked.

Applied, thanks.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
