Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E71D8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 03:44:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so8215684edb.5
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 00:44:06 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 12 Dec 2018 09:44:04 +0100
From: osalvador@suse.de
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
In-Reply-To: <20181210171656.GV1286@dhcp22.suse.cz>
References: <72455c1d4347d263cb73517187bc1394@suse.de>
 <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
 <39aa34058fc9641346456463afc2082d@suse.de>
 <20181205191244.GV1286@dhcp22.suse.cz>
 <42699b27-c214-91fd-e7e9-d34e16e9bf9f@suse.cz>
 <20181207103200.GV1286@dhcp22.suse.cz>
 <cd1e398acf86909f12b58bbde1c509ba@suse.de>
 <1946d97a057fe8d5953732350fb2a070@suse.de>
 <20181210171656.GV1286@dhcp22.suse.cz>
Message-ID: <854fc5713dda12c3572a21a226f2a2e0@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

>> Now, when dropping the shrink code and re-evaluating zone_contiguous 
>> in
>> offline
>> operation, set_zone_contiguous() will return false, leaving us with
>> zone_contiguous
>> unset.
> 
> Yeah. But does anything prevent us to alter the logic that the zone is
> not contiguous iff there are offline holes or zones intermixed.

Yes, thanks for the hint.
I think this is the best way to go.
