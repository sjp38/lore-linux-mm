Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 718116B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 16:51:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d3so35365027pfj.5
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 13:51:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q74si3801028pfi.346.2017.04.27.13.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 13:51:27 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	<1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
	<20170427143721.GK4706@dhcp22.suse.cz>
Date: Thu, 27 Apr 2017 13:51:23 -0700
In-Reply-To: <20170427143721.GK4706@dhcp22.suse.cz> (Michal Hocko's message of
	"Thu, 27 Apr 2017 16:37:21 +0200")
Message-ID: <87pofxk20k.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

Michal Hocko <mhocko@kernel.org> writes:

> On Tue 25-04-17 16:27:51, Laurent Dufour wrote:
>> When page are poisoned, they should be uncharged from the root memory
>> cgroup.
>> 
>> This is required to avoid a BUG raised when the page is onlined back:
>> BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
>> page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
>> index:0x1
>> flags: 0x3ffff800200000(hwpoison)
>
> My knowledge of memory poisoning is very rudimentary but aren't those
> pages supposed to leak and never come back? In other words isn't the
> hoplug code broken because it should leave them alone?

Yes that would be the right interpretation. If it was really offlined
due to a hardware error the memory will be poisoned and any access
could cause a machine check.

hwpoison has an own "unpoison" option (only used for debugging), which
I think handles this.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
