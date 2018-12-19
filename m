Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6CD8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:41:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so16573131edq.4
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 06:41:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p7-v6sor5331989ejb.30.2018.12.19.06.41.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 06:41:30 -0800 (PST)
Date: Wed, 19 Dec 2018 14:41:29 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219144129.rdmmif2agomvoutk@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219132934.65vymftfgd2atcxa@master>
 <20181219134056.GL5758@dhcp22.suse.cz>
 <20181219135635.yloh2sn4uskzpy7g@master>
 <20181219141235.GM5758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219141235.GM5758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed, Dec 19, 2018 at 03:12:35PM +0100, Michal Hocko wrote:
>On Wed 19-12-18 13:56:35, Wei Yang wrote:
>> On Wed, Dec 19, 2018 at 02:40:56PM +0100, Michal Hocko wrote:
>> >On Wed 19-12-18 13:29:34, Wei Yang wrote:
>[...]
>> >> As the comment mentioned, in current implementation the range must be in
>> >> one zone.
>> >
>> >I do not see anything like that documented for set_migratetype_isolate.
>> 
>> The comment is not on set_migratetype_isolate, but for its two
>> (grandparent) callers:
>> 
>>    __offline_pages
>>    alloc_contig_range
>
>But those are consumers while the main api here is
>start_isolate_page_range. What happens if we grow a new user?
>Go over the same problems? See the difference?

I didn't intend to fight for my patch, just want to clarify current
implementation :-)

>
>Please try to look at these things from a higher level. We really do not
>want micro optimise on behalf of a sane API. Unless there is a very good
>reason to do that - e.g. when the performance difference is really huge.

Well, actually I get your idea and agree with you not rely on the caller
to drain the page is the proper way to handle this.

Again, I just want to clarify current situation and try to find a proper
way to make it better. Maybe I lost some point, while I am willing get
feedback and suggestions from all of you.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
