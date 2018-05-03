Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB556B0003
	for <linux-mm@kvack.org>; Thu,  3 May 2018 20:13:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id o187-v6so1026287ito.2
        for <linux-mm@kvack.org>; Thu, 03 May 2018 17:13:13 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q82-v6si12444736ioi.137.2018.05.03.17.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 17:13:12 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
Date: Thu, 3 May 2018 15:39:49 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com



On 05/03/2018 11:03 AM, Christopher Lameter wrote:
> On Tue, 1 May 2018, Prakash Sangappa wrote:
>
>> For analysis purpose it is useful to have numa node information
>> corresponding mapped address ranges of the process. Currently
>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>> allocated per VMA of the process. This is not useful if an user needs to
>> determine which numa node the mapped pages are allocated from for a
>> particular address range. It would have helped if the numa node information
>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>> exact numa node from where the pages have been allocated.
> Cant you write a small script that scans the information in numa_maps and
> then displays the total pages per NUMA node and then a list of which
> ranges have how many pages on a particular node?

Don't think we can determine which numa node a given user process
address range has pages from, based on the existing 'numa_maps' file.

>> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
> So a prime motivator here is security restricted access to numa_maps?
No it is the opposite. A regular user should be able to determine
numa node information.
