Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF256B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 03:45:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so90916822lfg.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:45:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q126si19858886wme.10.2016.08.23.00.45.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 00:45:44 -0700 (PDT)
Date: Tue, 23 Aug 2016 09:45:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160823074542.GC23577@dhcp22.suse.cz>
References: <a61f01eb-7077-07dd-665a-5125a1f8ef37@suse.cz>
 <0325d79b-186b-7d61-2759-686f8afff0e9@Quantum.com>
 <20160817093323.GB20703@dhcp22.suse.cz>
 <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
 <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
 <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
 <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
 <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
 <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
 <20160823050252.GD17039@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823050252.GD17039@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue 23-08-16 14:02:52, Joonsoo Kim wrote:
[...]
> How about introducing one more priority (last priority) to allow scanning
> unmovable/reclaimable pageblock? If we don't reach that priority,
> long-term fragmentation can be avoided.

I have already suggested that. We would reach that priority only for
!costly orders. Vlastimil already has plans to cook up a patch for that
but he is on vacation...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
