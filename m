Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 66B346B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 14:09:20 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fl4so83130844pad.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 11:09:20 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id e25si30605797pfb.26.2016.03.07.11.09.19
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 11:09:19 -0800 (PST)
Date: Mon, 07 Mar 2016 14:09:15 -0500 (EST)
Message-Id: <20160307.140915.1323031236840000210.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <56DDC2B6.6020009@oracle.com>
References: <56DD9949.1000106@oracle.com>
	<20160307.115626.807716799249471744.davem@davemloft.net>
	<56DDC2B6.6020009@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Mon, 7 Mar 2016 11:04:38 -0700

> On 03/07/2016 09:56 AM, David Miller wrote:
>> From: Khalid Aziz <khalid.aziz@oracle.com>
>> Date: Mon, 7 Mar 2016 08:07:53 -0700
>>
>>> PR_GET_SPARC_ADICAPS
>>
>> Put this into a new ELF auxiliary vector entry via ARCH_DLINFO.
>>
>> So now all that's left is supposedly the TAG stuff, please explain
>> that to me so I can direct you to the correct existing interface to
>> provide that as well.
>>
>> Really, try to avoid prtctl, it's poorly typed and almost worse than
>> ioctl().
>>
> 
> The two remaining operations I am looking at are:
> 
> 1. Is PSTATE.mcde bit set for the process? PR_SET_SPARC_ADI provides
> this in its return value in the patch I sent.

Unnecessary.  If any ADI mappings exist then mcde is set, otherwise it is
clear.  This is internal state and the application has no need to every
set nor query it.

It is implicit from the mprotect() calls the user makes to enable ADI
regions.

> 2. Is TTE.mcd set for a given virtual address? PR_GET_SPARC_ADI_STATUS
> provides this function in the patch I sent.

Again, implied by the mprotect() calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
