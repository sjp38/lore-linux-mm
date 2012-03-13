Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id ED6FE6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 17:36:55 -0400 (EDT)
Date: Tue, 13 Mar 2012 14:36:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V3 3/8] hugetlb: add charge/uncharge calls for HugeTLB
 alloc/free
Message-Id: <20120313143654.5dd1243d.akpm@linux-foundation.org>
In-Reply-To: <1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 12:37:07 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> +		return ERR_PTR(-VM_FAULT_SIGBUS);

whee, so we have (ab)used the err.h infrastructure to carry
VM_FAULT_foo codes, thus creating a secret requirement that the
VM_FAULT_foo values not exceed MAX_ERRNO.

What a hack, whodidthat?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
