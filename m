Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4885A6B025E
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 11:54:12 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vd14so6079408pab.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:54:12 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 27si4470962pfn.124.2016.08.23.08.54.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 08:54:11 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: what is the purpose of SLAB and SLUB
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
	<20160818115218.GJ30162@dhcp22.suse.cz>
	<20160823021303.GB17039@js1304-P5Q-DELUXE>
	<20160823153807.GN23577@dhcp22.suse.cz>
Date: Tue, 23 Aug 2016 08:54:10 -0700
In-Reply-To: <20160823153807.GN23577@dhcp22.suse.cz> (Michal Hocko's message
	of "Tue, 23 Aug 2016 17:38:08 +0200")
Message-ID: <8760qr8orh.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jiri Slaby <jslaby@suse.cz>

Michal Hocko <mhocko@kernel.org> writes:
>
>> Anyway, we cannot remove one without regression so we don't remove one
>> until now. In this case, there is no point to stop improving one.
>
> I can completely see the reason to not drop SLAB (and I am not suggesting
> that) but I would expect that SLAB would be more in a feature freeze
> state. Or if both of them need to evolve then at least describe which
> workloads pathologically benefit/suffer from one or the other.

Why would you stop someone from working on SLAB if they want to?

Forcibly enforcing a freeze on something can make sense if you're
in charge of a team to conserve resources, but in Linux the situation is
very different.

Everyone works on what they (or their employer wants), not what
someone else wants. So if they want slab that is what they do.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
