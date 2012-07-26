Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 922FB6B004D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 10:05:42 -0400 (EDT)
Message-ID: <50114E05.1040201@parallels.com>
Date: Thu, 26 Jul 2012 18:02:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] slab: allow enable_cpu_cache to use preset values
 for its tunables
References: <1343227101-14217-1-git-send-email-glommer@parallels.com> <1343227101-14217-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207251204450.3543@router.home> <501039F9.7040309@parallels.com> <alpine.DEB.2.00.1207251331480.4995@router.home>
In-Reply-To: <alpine.DEB.2.00.1207251331480.4995@router.home>
Content-Type: multipart/mixed;
	boundary="------------010800000600070305040105"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Frederic Weisbecker <fweisbec@gmail.com>, devel@openvz.org, cgroups@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>

--------------010800000600070305040105
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 07/25/2012 10:33 PM, Christoph Lameter wrote:
> On Wed, 25 Jul 2012, Glauber Costa wrote:
> 
>> It is certainly not through does the same method as SLAB, right ?
>> Writing to /proc/slabinfo gives me an I/O error
>> I assume it is something through sysfs, but schiming through the code
>> now, I can't find any per-cache tunables. Would you mind pointing me to
>> them?
> 
> The slab attributes in /sys/kernel/slab/<slabname>/<attr> can be modified
> for some values. I think that could be the default method for the future
> since it allows easy addition of new tunables as needed.
> 

Christoph, would the following PoC patch be enough?



--------------010800000600070305040105
Content-Type: text/x-patch; name="0001-slub-propagation.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="0001-slub-propagation.patch"


--------------010800000600070305040105--
