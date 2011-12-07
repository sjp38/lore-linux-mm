Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8912B6B0072
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 20:42:14 -0500 (EST)
Received: by ghbg19 with SMTP id g19so54946ghb.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 17:42:13 -0800 (PST)
Date: Tue, 6 Dec 2011 17:42:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2]numa: add a sysctl to control interleave allocation
 granularity from each node
In-Reply-To: <20111207013754.GA23364@sli10-conroe.sh.intel.com>
Message-ID: <alpine.DEB.2.00.1112061739140.27247@chino.kir.corp.google.com>
References: <1323055846.22361.362.camel@sli10-conroe> <alpine.DEB.2.00.1112061248500.28251@chino.kir.corp.google.com> <20111207013754.GA23364@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "ak@linux.intel.com" <ak@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>

On Wed, 7 Dec 2011, Shaohua Li wrote:

> based on the allocation size, right? I did consider it. It would be easy to
> implement this. Note even without my patch we have the issue if allocation
> from one node is big order and small order from other node. And nobody
> complains the imbalance. This makes me think maybe people didn't care
> about the imbalance too much.
> 

Right, I certainly see what you're trying to do and I support it, however, 
if we're going to add a userspace tunable then I think it would be better 
implemented as a size.  You can still get the functionality that you have 
with your patch (just with a size of 0, the default, making every 
allocation on the next node) but can also interleave on PAGE_SIZE, 
HPAGE_SIZE, etc, increments.  I think it would help for users who are 
concerned about node symmetry for contention on the memory bus and it 
would be a shame if someone needed to add a second tunable for that affect 
if your tunable already has applications using it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
