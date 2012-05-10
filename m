Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 45B296B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 13:17:16 -0400 (EDT)
Message-ID: <4FABF80D.3040803@cs.wisc.edu>
Date: Thu, 10 May 2012 12:17:01 -0500
From: Mike Christie <michaelc@cs.wisc.edu>
MIME-Version: 1.0
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V10
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Content-Type: multipart/mixed;
 boundary="------------020903070100040605000103"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric B Munson <emunson@mgebm.net>

This is a multi-part message in MIME format.
--------------020903070100040605000103
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 05/10/2012 08:44 AM, Mel Gorman wrote:
> When a user or administrator requires swap for their application, they
> create a swap partition and file, format it with mkswap and activate it
> with swapon. Swap over the network is considered as an option in diskless
> systems. The two likely scenarios are when blade servers are used as part
> of a cluster where the form factor or maintenance costs do not allow the
> use of disks and thin clients.

Thank you for working on this. I made the attached patch for software
iscsi which has the same issue as nbd.

I tested the patch here and did not notice any performance regressions
or any other bugs.

--------------020903070100040605000103
Content-Type: text/plain; charset=UTF-8;
 name="0001-iscsi-Set-SOCK_MEMALLOC-for-access-to-PFMEMALLOC-res.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-iscsi-Set-SOCK_MEMALLOC-for-access-to-PFMEMALLOC-res.pa";
 filename*1="tch"


--------------020903070100040605000103--
