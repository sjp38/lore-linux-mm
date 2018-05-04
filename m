Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 753A06B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:18:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p190so15921556qkc.17
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:18:33 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g127si1653171qkb.90.2018.05.04.09.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 09:18:32 -0700 (PDT)
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
 <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
 <20180504111211.GO4535@dhcp22.suse.cz>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <de18dc06-6448-d6e5-fa80-c6065edd3aa4@oracle.com>
Date: Fri, 4 May 2018 09:18:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180504111211.GO4535@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com



On 5/4/18 4:12 AM, Michal Hocko wrote:
> On Thu 03-05-18 15:39:49, prakash.sangappa wrote:
>>
>> On 05/03/2018 11:03 AM, Christopher Lameter wrote:
>>> On Tue, 1 May 2018, Prakash Sangappa wrote:
>>>
>>>> For analysis purpose it is useful to have numa node information
>>>> corresponding mapped address ranges of the process. Currently
>>>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>>>> allocated per VMA of the process. This is not useful if an user needs to
>>>> determine which numa node the mapped pages are allocated from for a
>>>> particular address range. It would have helped if the numa node information
>>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>>> exact numa node from where the pages have been allocated.
>>> Cant you write a small script that scans the information in numa_maps and
>>> then displays the total pages per NUMA node and then a list of which
>>> ranges have how many pages on a particular node?
>> Don't think we can determine which numa node a given user process
>> address range has pages from, based on the existing 'numa_maps' file.
> yes we have. See move_pages...

Sure using move_pages, not based on just 'numa_maps'.

>   
>>>> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
>>> So a prime motivator here is security restricted access to numa_maps?
>> No it is the opposite. A regular user should be able to determine
>> numa node information.
> Well, that breaks the layout randomization, doesn't it?

Exposing numa node information itself should not break randomization right?

It would be upto the application. In case of randomization, the application
could generateA  address range traces of interest for debugging and then
using numa node information one could determine where the memory is laid
out for analysis.
