Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4B02B6B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 18:35:23 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id d205so91164036oia.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 15:35:23 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k205si9182oib.149.2016.03.07.15.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 15:35:22 -0800 (PST)
Message-ID: <56DE100E.7030109@oracle.com>
Date: Tue, 08 Mar 2016 10:34:38 +1100
From: James Morris <james.l.morris@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <56DDDA31.9090105@oracle.com>	<CALCETrXXU0fs2ezq+Wn_kr4dZTO=0RJmt6b=XBSA-wM7W_9j9A@mail.gmail.com>	<56DDE783.8090009@oracle.com> <20160307.155810.587016604208120674.davem@davemloft.net>
In-Reply-To: <20160307.155810.587016604208120674.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, khalid.aziz@oracle.com
Cc: luto@amacapital.net, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/08/2016 07:58 AM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Mon, 7 Mar 2016 13:41:39 -0700
>
>> Shared data may not always be backed by a file. My understanding is
>> one of the use cases is for in-memory databases. This shared space
>> could also be used to hand off transactions in flight to other
>> processes. These transactions in flight would not be backed by a
>> file. Some of these use cases might not use shmfs even. Setting ADI
>> bits at virtual address level catches all these cases since what backs
>> the tagged virtual address can be anything - a mapped file, mmio
>> space, just plain chunk of memory.
>
> Frankly the most interesting use case to me is simply finding bugs
> and memory scribbles, and for that we're want to be able to ADI
> arbitrary memory returned from malloc() and friends.
>
> I personally see ADI more as a debugging than a security feature,
> but that's just my view.

This is certainly a major use of the feature. The Solaris folks have 
made some interesting use of it here:

https://docs.oracle.com/cd/E37069_01/html/E37085/gphwb.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
