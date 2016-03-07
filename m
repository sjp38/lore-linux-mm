Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E13F86B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 17:31:07 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bj10so86377995pad.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 14:31:07 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q190si31610211pfq.247.2016.03.07.14.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 14:31:07 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <56DDC2B6.6020009@oracle.com>
 <20160307.140915.1323031236840000210.davem@davemloft.net>
 <56DDF22D.9090102@oracle.com>
 <20160307.163401.1082539079648850099.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DE00FF.1080807@oracle.com>
Date: Mon, 7 Mar 2016 15:30:23 -0700
MIME-Version: 1.0
In-Reply-To: <20160307.163401.1082539079648850099.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/07/2016 02:34 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Mon, 7 Mar 2016 14:27:09 -0700
>
>> I agree with your point of view. PSTATE.mcde and TTE.mcd are set in
>> response to request from userspace. If userspace asked for them to be
>> set, they already know but it was the database guys that asked for
>> these two functions and they are the primary customers for the ADI
>> feature. I am not crazy about this idea since this extends the
>> mprotect API even further but would you consider using the return
>> value from mprotect to indicate if PSTATE.mcde or TTE.mcd were already
>> set on the given address?
>
> Well, that's the idea.
>
> If the mprotect using MAP_ADI or whatever succeeds, then ADI is
> enabled.
>
> Users can thus also pass MAP_ADI as a flag to mmap() to get ADI
> protection from the very beginning.
>

MAP_ADI has been sitting in my backlog for some time. Looks like you 
just raised its priority ;)

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
