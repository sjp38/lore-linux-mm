Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA2E6B000E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:19:56 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id h2so12430768uae.1
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:19:56 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w5si92216uae.416.2018.03.19.08.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 08:19:55 -0700 (PDT)
Subject: Re: [PATCH v12 00/11] Application Data Integrity feature introduced
 by SPARC M7
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <20180318.110857.1660518649370410007.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <b9507686-6c3f-7fb1-b305-c1817f86a884@oracle.com>
Date: Mon, 19 Mar 2018 09:19:21 -0600
MIME-Version: 1.0
In-Reply-To: <20180318.110857.1660518649370410007.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: dave.hansen@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, allen.pais@oracle.com, aneesh.kumar@linux.vnet.ibm.com, anthony.yznaga@oracle.com, arnd@arndb.de, benh@kernel.crashing.org, bob.picco@oracle.com, bsingharora@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, dave.jiang@intel.com, david.j.aldridge@oracle.com, dwindsor@gmail.com, ebiederm@xmission.com, elena.reshetova@intel.com, gregkh@linuxfoundation.org, hannes@cmpxchg.org, henry.willard@oracle.com, hpa@zytor.com, hughd@google.com, imbrenda@linux.vnet.ibm.com, jack@suse.cz, jag.raman@oracle.com, jane.chu@oracle.com, jglisse@redhat.com, jroedel@suse.de, khalid@gonehiking.org, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, kstewart@linuxfoundation.org, ktkhai@virtuozzo.com, liam.merwick@oracle.com, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linuxram@us.ibm.com, linux@roeck-us.net, me@tobin.cc, mgorman@suse.de, mgorman@techsingularity.net, mhocko@suse.com, mike.kravetz@oracle.com, minchan@kernel.org, mingo@kernel.org

On 03/18/2018 09:08 AM, David Miller wrote:
> In uapi/asm/auxvec.h you conditionalize the ADI aux vectors on
> CONFIG_SPARC64.
> 
> That's not correct, you should never control user facing definitions
> based upon kernel configuration.
> 
> Also, both 32-bit and 64-bit applications running on ADI capable
> machines want to compile against and use this informaiton.
> 
> So please remove these CPP checks.
> 

Hi Dave,

That makes sense. I will send a patch to remove these.

Thanks,
Khalid
