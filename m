Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8356A6B005D
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 15:28:42 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2485336ghr.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 12:28:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339232401-14392-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 9 Jun 2012 15:28:21 -0400
Message-ID: <CAHGf_=oPLXvgPzeAn0Cn5Pni0NrdOzZ=hNTmAg5QACCzuv7z9A@mail.gmail.com>
Subject: Re: [PATCH -V8 02/16] hugetlb: don't use ERR_PTR with VM_FAULT* values
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat, Jun 9, 2012 at 4:59 AM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> The current use of VM_FAULT_* codes with ERR_PTR requires us to ensure
> VM_FAULT_* values will not exceed MAX_ERRNO value. Decouple the
> VM_FAULT_* values from MAX_ERRNO.
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

I like this much.

 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
