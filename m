Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9B16B0071
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:06:20 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so43752600pdb.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:06:20 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id be1si9915095pdb.228.2015.03.05.08.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 08:06:19 -0800 (PST)
Message-ID: <54F87EEC.9040000@oracle.com>
Date: Thu, 05 Mar 2015 11:06:04 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm track: THP topics
References: <20150305152155.GB19664@dhcp22.suse.cz> <54F87DEF.5030606@suse.cz>
In-Reply-To: <54F87DEF.5030606@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, lsf@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On 03/05/2015 11:01 AM, Vlastimil Babka wrote:
> On 03/05/2015 04:21 PM, Michal Hocko wrote:
>> > Hi,
>> > there is one THP related track scheduled currently but we have more THP
>> > topics which might be interesting IMO. Both Kirrill and Hugh have a very
>> > related topic so theirs should definitely stay.
>> > 
>> > Vlastimil has covered current pain points of THPs in his RFC recently
>> > (http://marc.info/?l=linux-mm&m=142469637313693&w=2). I think this
>> > deserves a separate slot so that we can discuss issues mentioned in the
>> > cover letter. There are still some slots free AFAICS.
>> > 
>> > What do you think?
> Yeah, it could be too much for a single slot. On the other hand the topic of THP
> costs/benefits could end up shorter due to lack of hard data. So if it's a time
> slot where we could flexibly move on to next topic without having to e.g.
> synchronize with a plenary session, it should work.

I've asked Vlastimil that question couple days ago and got the same answer :)

We have two spare slots which will probably stay open until the summit. Since
THP is the first (MM) topic on the agenda, if we see that there's more discussion
to do we can always grab one of the spares then.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
