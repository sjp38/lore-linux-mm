Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD68D830CB
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 16:47:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so166744547pfg.2
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:47:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id yp6si22939017pac.253.2016.08.26.13.47.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 13:47:47 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: what is the purpose of SLAB and SLUB
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
	<20160818115218.GJ30162@dhcp22.suse.cz>
	<20160823021303.GB17039@js1304-P5Q-DELUXE>
	<20160823153807.GN23577@dhcp22.suse.cz>
	<20160824082057.GT2693@suse.de>
	<alpine.DEB.2.20.1608242240460.1837@east.gentwo.org>
	<20160825100707.GU2693@suse.de>
	<alpine.DEB.2.20.1608251451070.10766@east.gentwo.org>
Date: Fri, 26 Aug 2016 13:47:47 -0700
In-Reply-To: <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org> (Christoph
	Lameter's message of "Thu, 25 Aug 2016 14:55:43 -0500 (CDT)")
Message-ID: <87h9a71clo.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

Christoph Lameter <cl@linux.com> writes:
>
>> If you want to rework the VM to use a larger fundamental unit, track
>> sub-units where required and deal with the internal fragmentation issues
>> then by all means go ahead and deal with it.
>
> Hmmm... The time problem is always there. Tried various approaches over
> the last decade. Could be a massive project. We really would need a
> larger group of developers to effectively do this.

I'm surprised that compactions is not able to fix the fragmentation.
Is the problem that there are too many non movable objects around?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
