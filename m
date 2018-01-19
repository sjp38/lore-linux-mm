Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B16ED6B0261
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 03:25:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f74so1191461pfa.13
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:25:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 68si8766119pfx.384.2018.01.19.00.25.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 00:25:19 -0800 (PST)
Date: Fri, 19 Jan 2018 09:25:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180119082517.GM6584@dhcp22.suse.cz>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180118171355.GH6584@dhcp22.suse.cz>
 <DM5PR1201MB01216B72BEF121DD25AB7247FDEF0@DM5PR1201MB0121.namprd12.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <DM5PR1201MB01216B72BEF121DD25AB7247FDEF0@DM5PR1201MB0121.namprd12.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "He, Roger" <Hongbo.He@amd.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "Koenig, Christian" <Christian.Koenig@amd.com>

[removed the broken quoting - please try to use an email client which
doesn't mess up the qouted text]

On Fri 19-01-18 06:01:26, He, Roger wrote:
[...]
> I think you are misunderstanding here.
> Actually for now, the memory in TTM Pools already has mm_shrink which is implemented in ttm_pool_mm_shrink_init.
> And here the memory we want to make it contribute to OOM badness is not in TTM Pools.
> Because when TTM buffer allocation success, the memory already is removed from TTM Pools.  

I have no idea what TTM buffers are. But this smells like something
rather specific to the particular subsytem. And my main objection here
is that struct file is not a proper vehicle to carry such an
information. So whatever the TTM subsystem does it should contribute to
generic counters rather than abuse fd because it happens to use it to
communicate with userspace.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
