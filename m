Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 177276B46CA
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:18:19 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so10156862edm.18
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:18:19 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Nov 2018 09:18:17 +0100
From: osalvador@suse.de
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
In-Reply-To: <20181127080035.GO12455@dhcp22.suse.cz>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
 <20181127080035.GO12455@dhcp22.suse.cz>
Message-ID: <d0d9c37f888cbb3037761ad9be647bcc@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 2018-11-27 09:00, Michal Hocko wrote:
> [I am mostly offline and will be so tomorrow as well]
> 
> On Tue 27-11-18 08:52:14, osalvador@suse.de wrote:
> [...]
>> So, although removing the lock here is pretty straightforward, it does 
>> not
>> really get us closer to that goal IMHO, if that is what we want to do 
>> in the
>> end.
> 
> But it doesn't get us further either, right? This patch shouldn't make
> any plan for range locking any worse. Both adding and removing a sparse
> section is pfn range defined unless I am missing something.

Yes, you are right, it should not have any impact.
It just felt like "we do already have the global lock, so let us stick 
with that".
But the less unneeded locks we have in our way, the better.

Sorry for the confusion.
