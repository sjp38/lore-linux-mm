Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 023F78E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:31:40 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id e126-v6so1802829ybb.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:31:39 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 189-v6si249879ywc.635.2018.09.12.06.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 06:31:38 -0700 (PDT)
Subject: Re: [RFC PATCH v2 2/8] mm: make zone_reclaim_stat updates thread-safe
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
 <20180911004240.4758-3-daniel.m.jordan@oracle.com>
 <fe814c4f-f049-9b7f-0f4c-7238f159f144@linux.vnet.ibm.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <7e0c2fe0-c867-3ea2-83a2-c3bcb35057d7@oracle.com>
Date: Wed, 12 Sep 2018 09:30:28 -0400
MIME-Version: 1.0
In-Reply-To: <fe814c4f-f049-9b7f-0f4c-7238f159f144@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

On 9/11/18 12:40 PM, Laurent Dufour wrote:
> On 11/09/2018 02:42, Daniel Jordan wrote:
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 32699b2dc52a..6d4c23a3069d 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -229,6 +229,12 @@ struct zone_reclaim_stat {
>>   	 *
>>   	 * The anon LRU stats live in [0], file LRU stats in [1]
>>   	 */
>> +	atomic_long_t		recent_rotated[2];
>> +	atomic_long_t		recent_scanned[2];
> 
> It might be better to use a slightly different name for these fields to
> distinguish them from the ones in the zone_reclaim_stat_cpu structure.

Sure, these are now named recent_rotated_cpu and recent_scanned_cpu, absent better names.

Thanks for your comments.
