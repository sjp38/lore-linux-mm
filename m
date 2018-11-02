Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 247C16B0008
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 08:41:41 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id t17-v6so1421356wmh.2
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 05:41:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v15-v6sor5846792wmd.6.2018.11.02.05.41.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 05:41:39 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz> <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <20181031170108.GR32673@dhcp22.suse.cz> <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
 <20181101132307.GJ23921@dhcp22.suse.cz> <CADF2uSqO8+_uZA5qHjWJ08UOqqH6C_d-_R+9qAAbxw5sdTYSMg@mail.gmail.com>
 <20181102080513.GB5564@dhcp22.suse.cz> <CADF2uSq+wP8aF=y=MgO4EHjk=ThXY22JMx81zNPy1kzheS6f3w@mail.gmail.com>
 <20181102114341.GB28039@dhcp22.suse.cz> <f95c4fdc-1b03-99dd-c293-3ee1e495305c@suse.cz>
In-Reply-To: <f95c4fdc-1b03-99dd-c293-3ee1e495305c@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Fri, 2 Nov 2018 13:41:26 +0100
Message-ID: <CADF2uSqtmaqaUqFiwiXGoLdDGHbMEPX5AqoA2quibwG0egJZPA@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

> >> any idea how to find out what that might be? I'd really have no idea,
> >> I also wonder why this never was an issue with 3.x
> >> find uses regex patterns, that's the only thing that may be unusual.
> >
> > The allocation tracepoint has the stack trace so that might help. This
>
> Well we already checked the mm_page_alloc traces and it seemed that only
> THP allocations could be the culprit. But apparently defrag=defer made
> no difference. I would still recommend it so we can see the effects on
> the traces. And adding tracepoints
> compaction/mm_compaction_try_to_compact_pages and
> compaction/mm_compaction_suitable as I suggested should show which
> high-order allocations actually invoke the compaction.

Anything in particular I should do to figure this out?
