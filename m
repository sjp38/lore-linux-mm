Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 73EED6B0002
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 14:27:27 -0400 (EDT)
Date: Tue, 30 Apr 2013 18:27:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] Make the batch size of the percpu_counter
 configurable
In-Reply-To: <1367344522.27102.184.camel@schen9-DESK>
Message-ID: <0000013e5c32f7fd-b4bf1b22-7924-42b5-b835-eb2b5926bbf6-000000@email.amazonses.com>
References: <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com> <0000013e5b24d2c5-9b899862-e2fd-4413-8094-4f1e5a0c0f62-000000@email.amazonses.com> <1367339009.27102.174.camel@schen9-DESK>
 <0000013e5bfd1548-a6ef7962-7b00-495b-8e83-d7a08413e165-000000@email.amazonses.com> <1367344094.27102.182.camel@schen9-DESK> <0000013e5c1377c5-49a8fca5-eb04-4e3a-a507-ce3a47fea685-000000@email.amazonses.com> <1367344522.27102.184.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 30 Apr 2013, Tim Chen wrote:

> > But you will have to dereference the pointer whenever you want the batch
> > size from the hot path. Looks like it would be better to put the value
> > there directly. You have a list of percpu counters that can be traversed
> > to change the batch size.
> >
>
> I have considered that.  But the list is not available unless we have
> CONFIG_HOTPLUG_CPU compiled in.

percpu counters are performance sensitive and with the pointer you
will need to reference another one increasing the cache footprint. You are
touching an additional cacheline somewhere in memory frequently. Not good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
