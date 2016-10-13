Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F07C6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 19:26:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j37so102230097ioo.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 16:26:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g67si6001226itb.55.2016.10.13.16.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 16:26:47 -0700 (PDT)
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
References: <57FF7BB4.1070202@redhat.com>
 <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com>
Date: Thu, 13 Oct 2016 16:26:36 -0700
MIME-Version: 1.0
In-Reply-To: <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: hillf.zj@alibaba-inc.com, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com

On 10/13/2016 08:24 AM, Mike Kravetz wrote:
> On 10/13/2016 05:19 AM, Jan Stancek wrote:
>> Hi,
>>
>> I'm running into ENOMEM failures with libhugetlbfs testsuite [1] on
>> a power8 lpar system running 4.8 or latest git [2]. Repeated runs of
>> this suite trigger multiple OOMs, that eventually kill entire system,
>> it usually takes 3-5 runs:
>>
>>  * Total System Memory......:  18024 MB
>>  * Shared Mem Max Mapping...:    320 MB
>>  * System Huge Page Size....:     16 MB
>>  * Available Huge Pages.....:     20
>>  * Total size of Huge Pages.:    320 MB
>>  * Remaining System Memory..:  17704 MB
>>  * Huge Page User Group.....:  hugepages (1001)
>>

Hi Jan,

Any chance you can get the contents of /sys/kernel/mm/hugepages
before and after the first run of libhugetlbfs testsuite on Power?
Perhaps a script like:

cd /sys/kernel/mm/hugepages
for f in hugepages-*/*; do
	n=`cat $f`;
	echo -e "$n\t$f";
done

Just want to make sure the numbers look as they should.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
