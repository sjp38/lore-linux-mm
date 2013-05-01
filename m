Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 16CCD6B018F
	for <linux-mm@kvack.org>; Wed,  1 May 2013 11:53:39 -0400 (EDT)
Subject: Re: [PATCH 1/2] Make the batch size of the percpu_counter
 configurable
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <51809F8D.3040305@gmail.com>
References: 
	 <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
	 <51809F8D.3040305@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 May 2013 08:53:39 -0700
Message-ID: <1367423619.27102.198.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 2013-05-01 at 12:52 +0800, Simon Jeons wrote:
> Hi Tim,
> On 04/30/2013 01:12 AM, Tim Chen wrote:
> > Currently, there is a single, global, variable (percpu_counter_batch) that
> > controls the batch sizes for every 'struct percpu_counter' on the system.
> >
> > However, there are some applications, e.g. memory accounting where it is
> > more appropriate to scale the batch size according to the memory size.
> > This patch adds the infrastructure to be able to change the batch sizes
> > for each individual instance of 'struct percpu_counter'.
> >
> > I have chosen to implement the added field of batch as a pointer
> > (by default point to percpu_counter_batch) instead
> > of a static value.  The reason is the percpu_counter initialization
> > can be called when we only have boot cpu and not all cpus are online.
> 
> What's the meaning of boot cpu? Do you mean cpu 0?
> 

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
