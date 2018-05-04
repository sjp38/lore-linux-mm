Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2DC6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 10:57:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id u23-v6so847750ioc.13
        for <linux-mm@kvack.org>; Fri, 04 May 2018 07:57:57 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id x63-v6si14068854iod.64.2018.05.04.07.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 07:57:56 -0700 (PDT)
Date: Fri, 4 May 2018 09:57:54 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node
 information
In-Reply-To: <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
Message-ID: <alpine.DEB.2.21.1805040955550.10847@nuc-kabylake>
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com> <alpine.DEB.2.21.1805031259210.7831@nuc-kabylake> <c80ee329-084b-367f-1937-3175c178e978@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com

On Thu, 3 May 2018, prakash.sangappa wrote:

> > > exact numa node from where the pages have been allocated.
> > Cant you write a small script that scans the information in numa_maps and
> > then displays the total pages per NUMA node and then a list of which
> > ranges have how many pages on a particular node?
>
> Don't think we can determine which numa node a given user process
> address range has pages from, based on the existing 'numa_maps' file.

Well the information is contained in numa_maps I thought. What is missing?

> > > reading this file will not be restricted(i.e requiring CAP_SYS_ADMIN).
> > So a prime motivator here is security restricted access to numa_maps?
> No it is the opposite. A regular user should be able to determine
> numa node information.

That used to be the case until changes were made to the permissions for
reading numa_maps.
