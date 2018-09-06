Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05EF76B7991
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 12:12:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l65-v6so5680568pge.17
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:12:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b79-v6si6298707pfc.156.2018.09.06.09.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 09:12:02 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
 <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
 <20180906151336.GD14951@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <33f39b37-9567-88a8-097d-a63df04c7732@intel.com>
Date: Thu, 6 Sep 2018 09:09:46 -0700
MIME-Version: 1.0
In-Reply-To: <20180906151336.GD14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/06/2018 08:13 AM, Michal Hocko wrote:
>> 	CONFIG_DEBUG_VM_SLOW_AS_HECK
>>
>> under which we can put this an other really slow VM debugging.  Or, we
>> need some kind of boot-time parameter to trigger the extra checking
>> instead of a new CONFIG option.
> I strongly suspect nobody will ever enable such a scary looking config
> TBH. Besides I am not sure what should go under that config option.

OK, so call it CONFIG_DEBUG_VM2, or CONFIG_DEBUG_VM_MORE. :)

What do we put under it?  The things that folks complain about that get
turned on with DEBUG_VM, like this.

> Is this worth a separate config option almost nobody is going to
> enable?
Yes.  We get basically *zero* debug checking from this option.  We want
it available to developers mucking with boot and hotplug, but it's
honestly not worth it for normal users.

Has anyone ever seen a single in-the-wild report from this mechanism?
