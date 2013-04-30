Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 337976B012C
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 13:34:36 -0400 (EDT)
Date: Tue, 30 Apr 2013 10:34:33 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 1/2] Make the batch size of the percpu_counter
 configurable
Message-ID: <20130430173433.GJ19487@tassilo.jf.intel.com>
References: <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
 <0000013e5b24d2c5-9b899862-e2fd-4413-8094-4f1e5a0c0f62-000000@email.amazonses.com>
 <1367339009.27102.174.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367339009.27102.174.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Hansen <dave.hansen@intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

> > What is this for and why does it have that alignmend?
> 
> I was assuming that if batch is frequently referenced, it probably
> should not share a cache line with the counters field.

As long as they are both read-mostly it should be fine to share
(cache line will just be SHARED)

Padding would be only useful if one gets changed regularly.
I don't think that's the case here?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
