Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7536B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:24:27 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so112894109pdb.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:24:27 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a4si10002308pdm.207.2015.03.20.09.24.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 09:24:26 -0700 (PDT)
Message-ID: <550C49B0.6070600@oracle.com>
Date: Fri, 20 Mar 2015 09:24:16 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] hugetlbfs: document min_size mount option
References: <cover.1426549010.git.mike.kravetz@oracle.com>	<3c82f2203e5453ddf3b29431863034afc7699303.1426549011.git.mike.kravetz@oracle.com>	<20150318144108.e235862e0be30ff626e01820@linux-foundation.org>	<550A2B9A.3060905@oracle.com> <20150318192324.e0386907.akpm@linux-foundation.org>
In-Reply-To: <20150318192324.e0386907.akpm@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/18/2015 07:23 PM, Andrew Morton wrote:
> On Wed, 18 Mar 2015 18:51:22 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>>> Nowhere here is the reader told the units of "size".  We should at
>>> least describe that, and maybe even rename the thing to min_bytes.
>>>
>>
>> Ok, I will add that the size is in unit of bytes.  My choice of
>> 'min_size' as a name for the new mount option was influenced by
>> the existing 'size' mount option.  I'm open to any suggestions
>> for the name of this new mount option.
>
> Yes, due to the preexisting "size" I think we're stuck with "min_size".
> We could use min_size_bytes I guess, but the operator needs to go look
> up the units of "size" anyway.
>

Well, the existing size option can also be specified as a percentage of
the huge page pool size.  This is in the current code.  There is a
mount option 'pagesize=' that allows one to select which huge page
(size) pool should be used. If none is specified the default huge page
pool is used.  There is no documentation for this pagesize option or
using size to specify a percentage of the huge page pool size.

I'll add this to the hugetlbpage.txt documentation.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
