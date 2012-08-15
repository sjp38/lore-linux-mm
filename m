Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C84956B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:11:54 -0400 (EDT)
Message-ID: <502BAE1D.7010507@parallels.com>
Date: Wed, 15 Aug 2012 18:11:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/11] kmem accounting basic infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-5-git-send-email-glommer@parallels.com> <20120814162144.GC6905@dhcp22.suse.cz> <502B6D03.1080804@parallels.com> <20120815123931.GF23985@dhcp22.suse.cz> <502B9BD4.4070003@parallels.com> <20120815130228.GH23985@dhcp22.suse.cz> <502B9E5F.2080907@parallels.com> <20120815132621.GJ23985@dhcp22.suse.cz> <502BA4AC.9040000@parallels.com> <20120815141041.GK23985@dhcp22.suse.cz>
In-Reply-To: <20120815141041.GK23985@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>


> OK, I missed an important point that kmem_accounted is not exported to
> the userspace (I thought it would be done later in the series) which
> is not the case so actually nobody get's confused by the inconsistency
> because it is about RESOURCE_MAX which they see in both cases.
> Sorry about the confusion!
> 
I'll forgive you this time...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
