Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0333E6B0270
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:47:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fn5so2748042pab.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:47:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 19si21302046pgc.314.2016.10.25.08.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 08:47:07 -0700 (PDT)
Subject: Re: [RFC 1/8] mm: Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-2-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4043.4090200@intel.com> <580EB3CB.5080200@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580F7E75.8080600@intel.com>
Date: Tue, 25 Oct 2016 08:47:01 -0700
MIME-Version: 1.0
In-Reply-To: <580EB3CB.5080200@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 06:22 PM, Anshuman Khandual wrote:
> On 10/24/2016 10:39 PM, Dave Hansen wrote:
>>> +#ifdef CONFIG_COHERENT_DEVICE
>>>> +#define node_cdm(nid)          (NODE_DATA(nid)->coherent_device)
>>>> +#define set_cdm_isolation(nid) (node_cdm(nid) = 1)
>>>> +#define clr_cdm_isolation(nid) (node_cdm(nid) = 0)
>>>> +#define isolated_cdm_node(nid) (node_cdm(nid) == 1)
>>>> +#else
>>>> +#define set_cdm_isolation(nid) ()
>>>> +#define clr_cdm_isolation(nid) ()
>>>> +#define isolated_cdm_node(nid) (0)
>>>> +#endif
>> FWIW, I think adding all this "cdm" gunk in the names is probably a bad
>> thing.
>>
>> I can think of other memory types that are coherent, but
>> non-device-based that might want behavior like this.
> 
> Hmm, I was not aware about non-device-based coherent memory. Could you
> please name some of them ? If thats the case we need to change CDM to
> some thing which can accommodate both device and non device based
> coherent memory. May be like "Differentiated/special coherent memory".
> But it needs to communicate that its not system RAM. Thats the idea.

Intel has some stuff called MCDRAM.  It's described in detail here:

> https://software.intel.com/en-us/articles/mcdram-high-bandwidth-memory-on-knights-landing-analysis-methods-tools

You can also Google around for more information.

I believe Samsung has a technology called High Bandwidth Memory (HBM)
that's already a couple of generations old that sounds similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
