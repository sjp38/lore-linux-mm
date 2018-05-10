Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE936B062B
	for <linux-mm@kvack.org>; Thu, 10 May 2018 12:36:38 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id f1-v6so1816652vkc.22
        for <linux-mm@kvack.org>; Thu, 10 May 2018 09:36:38 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e26-v6si287255ual.179.2018.05.10.09.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 09:36:37 -0700 (PDT)
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
 <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
 <20180504111211.GO4535@dhcp22.suse.cz>
 <de18dc06-6448-d6e5-fa80-c6065edd3aa4@oracle.com>
 <20180510074254.GE32366@dhcp22.suse.cz>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <ce2c36aa-8c03-63d6-e1ce-031197f45a5d@oracle.com>
Date: Thu, 10 May 2018 09:00:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180510074254.GE32366@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com



On 5/10/18 12:42 AM, Michal Hocko wrote:
> On Fri 04-05-18 09:18:11, Prakash Sangappa wrote:
>>
>> On 5/4/18 4:12 AM, Michal Hocko wrote:
>>> On Thu 03-05-18 15:39:49, prakash.sangappa wrote:
>>>> On 05/03/2018 11:03 AM, Christopher Lameter wrote:
>>>>> On Tue, 1 May 2018, Prakash Sangappa wrote:
>>>>>
>>>>>> For analysis purpose it is useful to have numa node information
>>>>>> corresponding mapped address ranges of the process. Currently
>>>>>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>>>>>> allocated per VMA of the process. This is not useful if an user needs to
>>>>>> determine which numa node the mapped pages are allocated from for a
>>>>>> particular address range. It would have helped if the numa node information
>>>>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>>>>> exact numa node from where the pages have been allocated.
>>>>> Cant you write a small script that scans the information in numa_maps and
>>>>> then displays the total pages per NUMA node and then a list of which
>>>>> ranges have how many pages on a particular node?
>>>> Don't think we can determine which numa node a given user process
>>>> address range has pages from, based on the existing 'numa_maps' file.
>>> yes we have. See move_pages...
>> Sure using move_pages, not based on just 'numa_maps'.
>>
>>>>>> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
>>>>> So a prime motivator here is security restricted access to numa_maps?
>>>> No it is the opposite. A regular user should be able to determine
>>>> numa node information.
>>> Well, that breaks the layout randomization, doesn't it?
>> Exposing numa node information itself should not break randomization right?
> I thought you planned to expose address ranges for each numa node as
> well. /me confused.

Yes, are you suggesting this information should not be available to a 
regular
user?

Is it not possible to get that same information using the move_pages() 
api as a regular
user, although one / set of pages at a time?


>> It would be upto the application. In case of randomization, the application
>> could generateA  address range traces of interest for debugging and then
>> using numa node information one could determine where the memory is laid
>> out for analysis.
> ... even more confused
>
