Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 251916B006E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 08:37:03 -0400 (EDT)
Received: by wgnd10 with SMTP id d10so71492249wgn.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 05:37:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hv2si14051541wib.70.2015.05.14.05.37.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 05:37:01 -0700 (PDT)
Date: Thu, 14 May 2015 14:36:29 +0200
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514123628.GA7300@rei>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514092301.GB6799@dhcp22.suse.cz>
 <20150514103542.GB5066@rei.suse.de>
 <20150514113101.GD6799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514113101.GD6799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, Nikolay Borisov <kernel@kyup.com>

Hi!
> > That would fail on older kernels without the patch, woudln't it?
> 
> Yes it will. I thought those would be using some stable release (I do
> not have much idea about the release process of ltp...). You are
> definitely right that a backward compatible way is better. I will cook
> up a patch later today.

The thing is that we do not have manpower to backport fixes to stable
releases. So the latest stable release is always recomended for testing
and because of that we have to fix testcases in backward compatible way.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
