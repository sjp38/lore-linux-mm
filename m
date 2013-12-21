Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 089566B0031
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 11:03:46 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so1585089eek.40
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 08:03:46 -0800 (PST)
Received: from bitsync.net (bitsync.net. [80.83.126.10])
        by mx.google.com with ESMTP id t6si13244677eeh.234.2013.12.21.08.03.45
        for <linux-mm@kvack.org>;
        Sat, 21 Dec 2013 08:03:45 -0800 (PST)
Message-ID: <52B5BBDF.9010200@bitsync.net>
Date: Sat, 21 Dec 2013 17:03:43 +0100
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/7] Configurable fair allocation zone policy v2r6
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <52B068B7.4070304@bitsync.net> <20131217212327.GL11295@suse.de>
In-Reply-To: <20131217212327.GL11295@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 17.12.2013 22:23, Mel Gorman wrote:
> On Tue, Dec 17, 2013 at 04:07:35PM +0100, Zlatko Calusic wrote:
>> On 13.12.2013 15:10, Mel Gorman wrote:
>>> Kicked this another bit today. It's still a bit half-baked but it restores
>>> the historical performance and leaves the door open at the end for playing
>>> nice with distributing file pages between nodes. Finishing this series
>>> depends on whether we are going to make the remote node behaviour of the
>>> fair zone allocation policy configurable or redefine MPOL_LOCAL. I'm in
>>> favour of the configurable option because the default can be redefined and
>>> tested while giving users a "compat" mode if we discover the new default
>>> behaviour sucks for some workload.
>>>
>>
>> I'll start a 5-day test of this patchset in a few hours, unless you
>> can send an updated one in the meantime. I intend to test it on a
>> rather boring 4GB x86_64 machine that before Johannes' work had lots
>> of trouble balancing zones. Would you recommend to use the default
>> settings, i.e. don't mess with tunables at this point?
>>
>
> For me at least I would prefer you tested v3 of the series with the
> default settings of not interleaving file-backed pages on remote nodes
> by default. Johannes might request testing with that knob enabled if the
> machine is NUMA although I doubt it is with 4G of RAM.
>

Tested v3 on UMA machine, with default setting. I see no regression, no 
issues whatsoever. From what I understand, this whole series is about 
fixing issues noticed on NUMA, so I wish you good luck with that (no 
such hardware here). Just be extra careful not to disturb finally very 
well balanced MM on more common machines (and especially those equipped 
with 4GB RAM). And once again thank you Johannes for your work, you did 
a great job.

Tested-by: Zlatko Calusic <zcalusic@bitsync.net>
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
