Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B95E6B0272
	for <linux-mm@kvack.org>; Fri,  4 May 2018 15:01:12 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o143-v6so3066825itg.9
        for <linux-mm@kvack.org>; Fri, 04 May 2018 12:01:12 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e19-v6si14374119ioe.69.2018.05.04.12.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 12:01:10 -0700 (PDT)
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
 <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
 <alpine.DEB.2.21.1805040955550.10847@nuc-kabylake>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <98e34010-d55a-5f2d-7d98-cba424de2e74@oracle.com>
Date: Fri, 4 May 2018 09:27:04 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1805040955550.10847@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com



On 5/4/18 7:57 AM, Christopher Lameter wrote:
> On Thu, 3 May 2018, prakash.sangappa wrote:
>
>>>> exact numa node from where the pages have been allocated.
>>> Cant you write a small script that scans the information in numa_maps and
>>> then displays the total pages per NUMA node and then a list of which
>>> ranges have how many pages on a particular node?
>> Don't think we can determine which numa node a given user process
>> address range has pages from, based on the existing 'numa_maps' file.
> Well the information is contained in numa_maps I thought. What is missing?

Currently 'numa_maps' gives a list of numa nodes, memory is allocated per
VMA.
Ex. we get something like from numa_maps.

04000A  N0=1,N2=2 kernelpagesize_KB=4

First is the start address of a VMA. This VMA could be much larger then 
3 4k pages.
It does not say which address in the VMA has the pages mapped.

>
>>>> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
>>> So a prime motivator here is security restricted access to numa_maps?
>> No it is the opposite. A regular user should be able to determine
>> numa node information.
> That used to be the case until changes were made to the permissions for
> reading numa_maps.
>
