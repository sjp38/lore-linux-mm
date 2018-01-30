Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27F046B0007
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:52:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f3so7747634pga.9
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:52:34 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0058.outbound.protection.outlook.com. [104.47.41.58])
        by mx.google.com with ESMTPS id b9si2804726pgf.430.2018.01.30.04.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 04:52:33 -0800 (PST)
Subject: Re: [PATCH] mm/swap: add function get_total_swap_pages to expose
 total_swap_pages
References: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
 <20180129163114.GH21609@dhcp22.suse.cz>
 <MWHPR1201MB01278542F6EE848ABD187BDBFDE40@MWHPR1201MB0127.namprd12.prod.outlook.com>
 <20180130075553.GM21609@dhcp22.suse.cz>
 <9060281e-62dd-8775-2903-339ff836b436@amd.com>
 <20180130101823.GX21609@dhcp22.suse.cz>
 <7d5ce7ab-d16d-36bc-7953-e1da2db350bf@amd.com>
 <20180130122853.GC21609@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <5ac13913-783d-26aa-ea5f-ab375f450f4c@amd.com>
Date: Tue, 30 Jan 2018 13:52:16 +0100
MIME-Version: 1.0
In-Reply-To: <20180130122853.GC21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "He, Roger" <Hongbo.He@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Am 30.01.2018 um 13:28 schrieb Michal Hocko:
> I do think you should completely ignore the size of the swap space. IMHO
> you should forbid further allocations when your current buffer storage
> cannot be reclaimed. So you need some form of feedback mechanism that
> would tell you: "Your buffers have grown too much".

Yeah well, that is exactly what we are trying to do here.

> If you cannot do
> that then simply assume that you cannot swap at all rather than rely on
> having some portion of it for yourself. There are many other users of
> memory outside of your subsystem. Any scaling based on the 50% of resource
> belonging to me is simply broken.

Our intention is not reserve 50% of resources to TTM, but rather allow 
TTM to abort when more than 50% of all resources are used up.

Rogers initial implementation didn't looked like that, but that is just 
a minor mistake we can fix.

Regards,
Christian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
