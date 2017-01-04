Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A19456B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 04:11:25 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id dh1so51762258wjb.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 01:11:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si51723560wme.5.2017.01.04.01.11.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 01:11:23 -0800 (PST)
Date: Wed, 4 Jan 2017 10:11:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er kernels
Message-ID: <20170104091120.GD25453@dhcp22.suse.cz>
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed 04-01-17 09:40:25, Gerhard Wiesinger wrote:
[...]
> Ok, 4.10.0-0.rc2.git0.1.fc26.x86_64 is not stable (4.9.0-1.fc26.x86_64 was).

Does the same happen with the vanilla kernels?

> The VM stops working (e.g. not pingable) after around 8h (will be restarted
> automatically), happened serveral times.
> 
> Had also further OOMs which I sent to Mincham.

Could you post them to the mailing list as well, please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
