Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 2FBF56B005C
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 21:59:29 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so2063192vcb.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 18:59:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339232401-14392-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1339232401-14392-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Sun, 10 Jun 2012 09:59:28 +0800
Message-ID: <CAJd=RBCRTj0BVdngyb7eHXCwB7pCp_tS6LNqmg1Uc-v_GbT4SQ@mail.gmail.com>
Subject: Re: [PATCH -V8 02/16] hugetlb: don't use ERR_PTR with VM_FAULT* values
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat, Jun 9, 2012 at 4:59 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> The current use of VM_FAULT_* codes with ERR_PTR requires us to ensure
> VM_FAULT_* values will not exceed MAX_ERRNO value. Decouple the
> VM_FAULT_* values from MAX_ERRNO.
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---

Thank you, AKKV.

Acked-by: Hillf Danton <dhillf@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
