Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 179796B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 13:24:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so3135815pfg.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:24:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k82si9821241pfb.180.2016.08.12.10.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 10:24:13 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7CHKZhr087179
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 13:24:12 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24s2v8gjbn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 13:24:12 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Fri, 12 Aug 2016 11:24:11 -0600
Date: Fri, 12 Aug 2016 12:24:03 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] powerpc/mm: allow memory hotplug into a memoryless
 node
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1470680843-28702-4-git-send-email-arbab@linux.vnet.ibm.com>
 <7d943111-d243-ffb3-ff5f-6d712c268e67@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <7d943111-d243-ffb3-ff5f-6d712c268e67@gmail.com>
Message-Id: <20160812172402.GA31526@arbab-vm.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 12, 2016 at 11:50:43AM +1000, Balbir Singh wrote:
>On 09/08/16 04:27, Reza Arbab wrote:
>> Remove the check which prevents us from hotplugging into an empty node.
>
>Do we want to do this only for ibm,hotplug-aperture compatible ranges?

We could, but since past discussions and current testing have been 
unable to justify preventing hotplug to a memoryless node in the first 
place, I'm inclined to keep things simple.

If some edge case is discovered, making it conditional as you describe 
will be a good solution.

Thanks for your review! A v2 of this set is pending my investigation of 
Michael's suggestion to get node hotadd working.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
