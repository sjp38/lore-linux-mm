Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0A8F86B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 04:17:31 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id t1so1481756dae.23
        for <linux-mm@kvack.org>; Thu, 21 Mar 2013 01:17:31 -0700 (PDT)
Message-ID: <514AC211.2030500@gmail.com>
Date: Thu, 21 Mar 2013 16:17:21 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH -V2 00/21] THP support for PPC64
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hi Aneesh,
On 02/22/2013 12:47 AM, Aneesh Kumar K.V wrote:
> Hi,
>
> This patchset adds transparent huge page support for PPC64.
>
> I am marking the series to linux-mm because the PPC64 implementation
> required few interface changes to core THP code. I still have considerable
> number of FIXME!! in the patchset mostly related to PPC64 mm susbsytem.
> Those would require closer review and once we are clear on those changes,
> I will drop those FIXME!! with necessary comments.
>
> Some numbers:
>
> The latency measurements code from Anton  found at
> http://ozlabs.org/~anton/junkcode/latency2001.c

Can this benchmark use for x86?

>
> THP disabled 64K page size
> ------------------------
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    731.73 cycles    205.77 ns
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    743.39 cycles    209.05 ns
> [root@llmp24l02 ~]#
>
> THP disabled large page via hugetlbfs
> -------------------------------------
> [root@llmp24l02 ~]# ./latency2001  -l 8G
>   8589934592    416.09 cycles    117.01 ns
> [root@llmp24l02 ~]# ./latency2001  -l 8G
>   8589934592    415.74 cycles    116.91 ns
>
> THP enabled 64K page size.
> ----------------
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    405.07 cycles    113.91 ns
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    411.82 cycles    115.81 ns
> [root@llmp24l02 ~]#
>
>
> We are close to hugetlbfs in latency and we can achieve this with zero
> config/page reservation. Most of the allocations above are fault allocated.
> I haven't really measured the collapse alloc impact.
>
> Another test that does 50000000 random access over 1GB area goes from
> 2.65 seconds to 1.07 seconds with this patchset.
>
> Changes from RFC V1:
> * HugeTLB fs now works
> * Compile issues fixed
> * rebased to v3.8
> * Patch series reorded so that ppc64 cleanups and MM THP changes are moved
>    early in the series. This should help in picking those patches early.
>
> Thanks,
> -aneesh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
