Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF0426B0038
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 12:51:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y77so6148943pfd.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:51:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s187si11309766pfs.374.2017.09.14.09.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 09:51:00 -0700 (PDT)
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
 <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A07E9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFzotfXc07UoVtxvDpQOP8tEt8pgxeYe+cGs=BDUC_A4pA@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F077537A1C19@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwECeY-x=_du67qAxkta_0LeUw_BQA1kP337SBV3znN2Q@mail.gmail.com>
 <bd2d09ea-47d1-c0a7-8d4d-604bb4bc28bc@linux.intel.com>
 <CA+55aFx3WY00yvEDBg7TagX4h_-QO71=HAq5GAT8awtewRXONQ@mail.gmail.com>
 <a9e74f64-dee6-dc23-128e-8ef8c7383d77@linux.intel.com>
 <CA+55aFx1aBJeq0AsRBsq_mguBz4Qo1fRygn-a19BcMvBA=J=ug@mail.gmail.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <67545647-1371-4540-84ae-e33d1c5c8465@linux.intel.com>
Date: Thu, 14 Sep 2017 09:50:53 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFx1aBJeq0AsRBsq_mguBz4Qo1fRygn-a19BcMvBA=J=ug@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------6FCB008D4044BC0FB06AB2CD"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------6FCB008D4044BC0FB06AB2CD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 09/13/2017 07:27 PM, Linus Torvalds wrote:
> On Wed, Sep 13, 2017 at 7:12 PM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>
>> BTW, will you be merging these 2 patches in 4.14?
> 
> Yes, and thanks for reminding me.
> 
> In fact, would you mind sending me the latest versions, rather than me
> digging them out of the disaster area that is my mailbox and possibly
> picking an older version?
> 
>                  Linus
> 

Attached the two patches that you have updated to sync with your other
page wait queue clean up and sent to Kan and me:
https://marc.info/?l=linux-kernel&m=150393893927105&w=2

Kan tested this before so it should be still good. 
I checked that it applied cleanly on latest master.

Thanks.

Tim

--------------6FCB008D4044BC0FB06AB2CD
Content-Type: text/x-patch;
 name="0001-sched-wait-Break-up-long-wake-list-walk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-sched-wait-Break-up-long-wake-list-walk.patch"


--------------6FCB008D4044BC0FB06AB2CD--
