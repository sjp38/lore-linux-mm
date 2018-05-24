Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8FB6B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 03:23:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bd7-v6so482549plb.20
        for <linux-mm@kvack.org>; Thu, 24 May 2018 00:23:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8-v6si19807564plk.0.2018.05.24.00.23.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 00:23:28 -0700 (PDT)
Subject: Re: [Bug 199763] System is unresponsive, or completely frozen on high
 memory usage
References: <bug-199763-27@https.bugzilla.kernel.org/>
 <bug-199763-27-KF5s1fxs8M@https.bugzilla.kernel.org/>
 <20180522144158.c344458466ca9d2a450197f2@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <002272a7-e8d4-1247-7ee3-5f2de9428d95@suse.cz>
Date: Thu, 24 May 2018 09:23:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180522144158.c344458466ca9d2a450197f2@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/22/2018 11:41 PM, Andrew Morton wrote:
> On Mon, 21 May 2018 23:30:03 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=199763
>>
> 
> And https://bugzilla.kernel.org/show_bug.cgi?id=196729
> 
> Basically, we suck.  And have done for 11 years.

Yep, my laptop has just 8GB RAM and recently I've got used to running
alt-sysrq-f at least once a day. Usually the culprit/victim is a Firefox
tab with the blue website.

I'm afraid upgrading to more RAM will be easier than fixing this, even
with the corporate IT processes :/ Or maybe the psi work from the people
running said website will help?
