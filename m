Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E863C6B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 09:13:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id u6-v6so1152092eds.10
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 06:13:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x33-v6si6881998edc.361.2018.11.02.06.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 06:13:49 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <20181031170108.GR32673@dhcp22.suse.cz>
 <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
 <20181101132307.GJ23921@dhcp22.suse.cz>
 <CADF2uSqO8+_uZA5qHjWJ08UOqqH6C_d-_R+9qAAbxw5sdTYSMg@mail.gmail.com>
 <20181102080513.GB5564@dhcp22.suse.cz>
 <CADF2uSq+wP8aF=y=MgO4EHjk=ThXY22JMx81zNPy1kzheS6f3w@mail.gmail.com>
 <20181102114341.GB28039@dhcp22.suse.cz>
 <f95c4fdc-1b03-99dd-c293-3ee1e495305c@suse.cz>
 <CADF2uSqtmaqaUqFiwiXGoLdDGHbMEPX5AqoA2quibwG0egJZPA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <63091aac-0caa-6740-1c91-cbc420612d74@suse.cz>
Date: Fri, 2 Nov 2018 14:13:46 +0100
MIME-Version: 1.0
In-Reply-To: <CADF2uSqtmaqaUqFiwiXGoLdDGHbMEPX5AqoA2quibwG0egJZPA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On 11/2/18 1:41 PM, Marinko Catovic wrote:
>>>> any idea how to find out what that might be? I'd really have no idea,
>>>> I also wonder why this never was an issue with 3.x
>>>> find uses regex patterns, that's the only thing that may be unusual.
>>>
>>> The allocation tracepoint has the stack trace so that might help. This
>>
>> Well we already checked the mm_page_alloc traces and it seemed that only
>> THP allocations could be the culprit. But apparently defrag=defer made
>> no difference. I would still recommend it so we can see the effects on
>> the traces. And adding tracepoints
>> compaction/mm_compaction_try_to_compact_pages and
>> compaction/mm_compaction_suitable as I suggested should show which
>> high-order allocations actually invoke the compaction.
> 
> Anything in particular I should do to figure this out?

Setup the same monitoring as before, but with two additional tracepoints
(echo 1 > .../enable) and once the problem appears, provide the tracing
output.
