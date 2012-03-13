Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id F38206B007E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 17:49:32 -0400 (EDT)
Date: Tue, 13 Mar 2012 14:49:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V3 0/8] memcg: Add memcg extension to control HugeTLB
 allocation
Message-Id: <20120313144930.284228c4.akpm@linux-foundation.org>
In-Reply-To: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 12:37:04 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> This patchset implements a memory controller extension to control
> HugeTLB allocations.

Well, why?  What are the use cases?  Who is asking for this?  Why do
they need it and how will they use it?  etcetera.

Please explain, with some care, why you think we should add this
feature to the kernel.  So that others can assess whether the value it
adds is worth the cost of adding and maintaining it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
