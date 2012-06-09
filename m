Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 52FF46B0062
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 04:22:32 -0400 (EDT)
Message-ID: <4FD30720.6040908@parallels.com>
Date: Sat, 9 Jun 2012 12:19:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] Add a __GFP_SLABMEMCG flag
References: <1339148601-20096-1-git-send-email-glommer@parallels.com> <1339148601-20096-3-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206081430380.4213@router.home>
In-Reply-To: <alpine.DEB.2.00.1206081430380.4213@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbeck@gmail.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On 06/08/2012 11:31 PM, Christoph Lameter wrote:
> Please make this conditional on CONFIG_MEMCG or so. The bit can be useful
> in particular on 32 bit architectures.
Looking at how __GFP_NOTRACK works - which is also ifdef'd, the bit it 
uses is skipped if that is not defined, which I believe is a sane thing 
to do.

Given that, I don't see the point of conditionally defining the memcg 
bit, It basically means that the only way we can reuse the bit saved is 
by making a future feature fundamentally incompatible with memcg.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
