Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1282A6B4884
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:50:15 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id 194-v6so14062885ywp.12
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:50:15 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r26si2996428ywa.463.2018.11.27.06.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 06:50:14 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181127131707.GW12455@dhcp22.suse.cz>
Date: Tue, 27 Nov 2018 07:50:08 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <04647F77-FE93-4A8E-90C1-4245709B88A5@oracle.com>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-4-mhocko@kernel.org>
 <0ACDD94B-75AD-4DD0-B2E3-32C0EDFBAA5E@oracle.com>
 <20181127131707.GW12455@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>



> On Nov 27, 2018, at 6:17 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> This is only about the process wide flag to disable THP. I do not see
> how this can be alighnement related. I suspect you wanted to ask in the
> smaps patch?

No, answered below.

> 
>> I'm having to deal with both these issues in the text page THP
>> prototype I've been working on for some time now.
> 
> Could you be more specific about the issue and how the alignment comes
> into the game? The only thing I can think of is to not report VMAs
> smaller than the THP as eligible. Is this what you are looking for?

Basically, if the faulting VA is one that cannot be mapped with a THP
due to alignment or size constraints, it may be "eligible" for THP
mapping but ultimately can't be.

I was just double checking that this was meant to be more of a check done
before code elsewhere performs additional checks and does the actual THP
mapping, not an all-encompassing go/no go check for THP mapping.

    Thanks,
         William Kucharski
