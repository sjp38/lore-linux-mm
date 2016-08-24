Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 751F16B0253
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 22:18:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so6451911pfd.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 19:18:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q11si6857557pfd.42.2016.08.23.19.18.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 19:18:26 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
	<20160817005905.GA5372@bbox>
	<87eg5gij57.fsf@yhuang-mobile.sh.intel.com>
	<20160824010036.GA27022@bbox>
Date: Tue, 23 Aug 2016 19:18:25 -0700
In-Reply-To: <20160824010036.GA27022@bbox> (Minchan Kim's message of "Wed, 24
	Aug 2016 10:00:36 +0900")
Message-ID: <87lgzmgb9q.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On my side, there are more urgent works now so I didn't have a time to
> see our ongoing discussion. I will continue after settle down works,
> maybe next week. Sorry.

No problem.  Thanks for your review so far!

> On Mon, Aug 22, 2016 at 02:33:08PM -0700, Huang, Ying wrote:
>> Hi, Minchan,
>> 
>> Minchan Kim <minchan@kernel.org> writes:
>> > Anyway, I hope [1/11] should be merged regardless of the patchset because
>> > I believe anyone doesn't feel comfortable with cluser_info functions. ;-)
>> 
>> I want to send out 1/11 separately.  Can I add your "Acked-by:" for it?
>
> Sure.

Thanks!

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
