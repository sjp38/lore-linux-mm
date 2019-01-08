Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 016628E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:37:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so1535610eda.3
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:37:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l12si1863662edi.230.2019.01.08.03.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:37:48 -0800 (PST)
Date: Tue, 8 Jan 2019 12:37:46 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <047f0582-a4d3-490d-7284-48dfdf9e9471@petrovitsch.priv.at>
Message-ID: <nycvar.YFH.7.76.1901081235380.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz> <nycvar.YFH.7.76.1901052016250.16954@cbobk.fhfr.pm> <fb0414ea-953b-0252-b1d1-12028b190949@suse.cz>
 <047f0582-a4d3-490d-7284-48dfdf9e9471@petrovitsch.priv.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue, 8 Jan 2019, Bernd Petrovitsch wrote:

> Shouldn't the application use e.g. mlock()/.... to guarantee no page 
> faults in the first place?

Calling mincore() on pages you've just mlock()ed is sort of pointless 
though.

-- 
Jiri Kosina
SUSE Labs
