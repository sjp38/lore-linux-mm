Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82A4D6B0702
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 10:42:22 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c15-v6so1589442pls.15
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 07:42:22 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id x5-v6si7665494plv.256.2018.11.09.07.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 07:42:21 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 09 Nov 2018 21:12:20 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v3 4/4] mm: Remove managed_page_count spinlock
In-Reply-To: <20181108101400.GU27423@dhcp22.suse.cz>
References: <1541665398-29925-1-git-send-email-arunks@codeaurora.org>
 <1541665398-29925-5-git-send-email-arunks@codeaurora.org>
 <20181108083400.GQ27423@dhcp22.suse.cz>
 <4e5e2923a424ab2e2c50e56b2e538a3c@codeaurora.org>
 <20181108101400.GU27423@dhcp22.suse.cz>
Message-ID: <4eded31079a6bc3b275ef619204c3509@codeaurora.org>
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
> 0day will throw a lot of random configs which can reveal some 
> leftovers.

0day sent one more failure. Will fix that and resend one more version.

Regards,
Arun
