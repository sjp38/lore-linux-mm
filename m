Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76C156B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 10:50:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f19-v6so13904775pgv.4
        for <linux-mm@kvack.org>; Fri, 04 May 2018 07:50:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g59-v6si16692976plb.381.2018.05.04.07.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 07:50:56 -0700 (PDT)
Date: Fri, 4 May 2018 10:50:52 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [v2] mm: access to uninitialized struct page
Message-ID: <20180504105052.429106ca@gandalf.local.home>
In-Reply-To: <CAGM2rebLfmWLybzNDPt-HTjZY2brkJ_8Bq37xVG_QDs=G+VuxQ@mail.gmail.com>
References: <20180426202619.2768-1-pasha.tatashin@oracle.com>
	<20180504082731.GA2782@outlook.office365.com>
	<CAGM2rebLfmWLybzNDPt-HTjZY2brkJ_8Bq37xVG_QDs=G+VuxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: avagin@virtuozzo.com, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

On Fri, 04 May 2018 12:47:53 +0000
Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Hi Andrei,
> 
> Could you please provide me with scripts to reproduce this issue?
> 
>

And the config that was used. Just saying that the commit doesn't boot
isn't very useful.

-- Steve
