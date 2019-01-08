Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 152328E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:15:05 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id j24-v6so784469lji.20
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:15:05 -0800 (PST)
Received: from esgaroth.tuxoid.at (esgaroth.petrovitsch.at. [78.47.184.11])
        by mx.google.com with ESMTPS id z65-v6si56368276ljb.17.2019.01.08.01.15.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Jan 2019 01:15:02 -0800 (PST)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz>
 <nycvar.YFH.7.76.1901052016250.16954@cbobk.fhfr.pm>
 <fb0414ea-953b-0252-b1d1-12028b190949@suse.cz>
From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Message-ID: <047f0582-a4d3-490d-7284-48dfdf9e9471@petrovitsch.priv.at>
Date: Tue, 8 Jan 2019 10:14:23 +0100
MIME-Version: 1.0
In-Reply-To: <fb0414ea-953b-0252-b1d1-12028b190949@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Jiri Kosina <jikos@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On 05/01/2019 20:38, Vlastimil Babka wrote:
[...]
> I was thinking about "return true" here, assuming that userspace generally wants
> to ensure itself there won't be page faults when it starts doing something
> critical, and if it sees a "false" it will try to do some kind of prefaulting,
> possibly in a loop. There might be somebody trying to make sure something is out

Isn't that racy by design as the pages may get flushed out after the check?
Shouldn't the application use e.g. mlock()/.... to guarantee no page
faults in the first place?

MfG,
	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at
