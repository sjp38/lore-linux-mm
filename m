Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEA46B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 14:03:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x79so3855995qkb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2018 11:03:54 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id q23si2967238qkh.42.2018.05.03.11.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 11:03:53 -0700 (PDT)
Date: Thu, 3 May 2018 13:03:51 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node
 information
In-Reply-To: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
Message-ID: <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake>
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com

On Tue, 1 May 2018, Prakash Sangappa wrote:

> For analysis purpose it is useful to have numa node information
> corresponding mapped address ranges of the process. Currently
> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
> allocated per VMA of the process. This is not useful if an user needs to
> determine which numa node the mapped pages are allocated from for a
> particular address range. It would have helped if the numa node information
> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
> exact numa node from where the pages have been allocated.

Cant you write a small script that scans the information in numa_maps and
then displays the total pages per NUMA node and then a list of which
ranges have how many pages on a particular node?

> reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).

So a prime motivator here is security restricted access to numa_maps?
