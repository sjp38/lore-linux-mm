Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C99C78E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 05:35:02 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so1719411edt.23
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 02:35:02 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 07 Dec 2018 11:35:00 +0100
From: osalvador@suse.de
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
In-Reply-To: <20181207103200.GV1286@dhcp22.suse.cz>
References: <72455c1d4347d263cb73517187bc1394@suse.de>
 <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
 <39aa34058fc9641346456463afc2082d@suse.de>
 <20181205191244.GV1286@dhcp22.suse.cz>
 <42699b27-c214-91fd-e7e9-d34e16e9bf9f@suse.cz>
 <20181207103200.GV1286@dhcp22.suse.cz>
Message-ID: <cd1e398acf86909f12b58bbde1c509ba@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 2018-12-07 11:32, Michal Hocko wrote:
> On Fri 07-12-18 10:54:50, Vlastimil Babka wrote:
>> Well, __pageblock_pfn_to_page() has to be called for each pageblock in
>> compaction, when zone_contiguous is false. And that's unchanged since
>> the introduction of zone_contiguous, so the numbers should still hold.
> 
> OK, this means that we have to carefully re-evaluate zone_contiguous 
> for
> each offline operation.

Yeah, it seems so.
I already thought about something, although I did not really think it 
through completely due to lack of time.
I expect to be able to start the patch early next week.

thanks Vlastimil for confirming ;-)
