Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76A386B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 04:45:23 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v2-v6so9062118wrr.10
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 01:45:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8-v6si1033713wri.178.2018.07.30.01.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 01:45:22 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm: proc/pid/smaps: factor out mem stats gathering
References: <20180723111933.15443-1-vbabka@suse.cz>
 <20180723111933.15443-3-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b45f319f-cd04-337b-37f8-77f99786aa8a@suse.cz>
Date: Mon, 30 Jul 2018 10:45:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180723111933.15443-3-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org

(moved thread here)

On 07/26/2018 06:21 PM, Alexey Dobriyan wrote:
> On Wed, Jul 25, 2018 at 08:55:17AM +0200, Vlastimil Babka wrote:
>> On 07/24/2018 08:24 PM, Alexey Dobriyan wrote:
>>> On Mon, Jul 23, 2018 at 04:55:46PM -0700, akpm@linux-foundation.org wrote:
>>>> The patch titled
>>>>      Subject: mm: /proc/pid/smaps: factor out common stats printing
>>>> has been added to the -mm tree.  Its filename is
>>>>      mm-proc-pid-smaps-factor-out-common-stats-printing.patch
>>>> +/* Show the contents common for smaps and smaps_rollup */
>>>> +static void __show_smap(struct seq_file *m, struct mem_size_stats *mss)
>>> This can be "const".
>> What exactly, mss?
> Yes, of course.
> seq_file is changed by virtue of priting to it.

----8<----
