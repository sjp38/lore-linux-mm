Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id C86EA6810BF
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 10:12:43 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v67so30418902ywg.4
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 07:12:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x14si1563892ybe.577.2017.08.25.07.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 07:12:42 -0700 (PDT)
Subject: Re: [RFC PATCH v2 1/7] ktask: add documentation
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
 <20170824205004.18502-2-daniel.m.jordan@oracle.com>
 <ebada9e9-038c-71b5-2115-1693cd1e202e@infradead.org>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <b460a898-f915-9c5f-e185-2348a657ddfd@oracle.com>
Date: Fri, 25 Aug 2017 10:12:04 -0400
MIME-Version: 1.0
In-Reply-To: <ebada9e9-038c-71b5-2115-1693cd1e202e@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

On 08/24/2017 07:07 PM, Randy Dunlap wrote:
> On 08/24/2017 01:49 PM, Daniel Jordan wrote:
>> diff --git a/Documentation/core-api/ktask.rst b/Documentation/core-api/ktask.rst
>> new file mode 100644
>> index 000000000000..cb4b0d87c8c6
>> --- /dev/null
>> +++ b/Documentation/core-api/ktask.rst
>> @@ -0,0 +1,104 @@
>> +============================================
>> +ktask: parallelize cpu-intensive kernel work
>> +============================================
> Hi,
>
> I would prefer to use CPU instead of cpu.

Ok, a quick grep through Documentation shows that CPU is used more often 
than cpu, so for consistency I'll change it.

> Otherwise, Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

Thanks for the review, Randy.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
