Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D83F6B05CF
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:31:12 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j1-v6so18495651pll.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:31:12 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id b8-v6si4117637plm.190.2018.11.08.02.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 02:31:11 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 08 Nov 2018 16:01:10 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v3 4/4] mm: Remove managed_page_count spinlock
In-Reply-To: <20181108101400.GU27423@dhcp22.suse.cz>
References: <1541665398-29925-1-git-send-email-arunks@codeaurora.org>
 <1541665398-29925-5-git-send-email-arunks@codeaurora.org>
 <20181108083400.GQ27423@dhcp22.suse.cz>
 <4e5e2923a424ab2e2c50e56b2e538a3c@codeaurora.org>
 <20181108101400.GU27423@dhcp22.suse.cz>
Message-ID: <e3ca027726d9683a9fbf3694a96afd17@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2018-11-08 15:44, Michal Hocko wrote:
> On Thu 08-11-18 15:33:06, Arun KS wrote:
>> On 2018-11-08 14:04, Michal Hocko wrote:
>> > On Thu 08-11-18 13:53:18, Arun KS wrote:
>> > > Now totalram_pages and managed_pages are atomic varibles. No need
>> > > of managed_page_count spinlock.
>> >
>> > As explained earlier. Please add a motivation here. Feel free to reuse
>> > wording from
>> > http://lkml.kernel.org/r/20181107103630.GF2453@dhcp22.suse.cz
>> 
>> Sure. Will add in next spin.
> 
> Andrew usually updates changelogs if you give him the full wording.
> I would wait few days before resubmitting, if that is needed at all.

mm: Remove managed_page_count spinlock

Now that totalram_pages and managed_pages are atomic varibles, no need
of managed_page_count spinlock. The lock had really a weak consistency
guarantee. It hasn't been used for anything but the update but no reader
actually cares about all the values being updated to be in sync.

Signed-off-by: Arun KS <arunks@codeaurora.org>
Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>


> 0day will throw a lot of random configs which can reveal some 
> leftovers.

Yea. Fixed few of them during v3.

Regards,
Arun
