Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA756B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 20:29:05 -0500 (EST)
Date: Thu, 5 Feb 2009 17:28:58 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch] mm: Fix SHM_HUGETLB to work with users in
	hugetlb_shm_group
Message-ID: <20090206012858.GB8946@localdomain>
References: <20090204220428.GA6794@localdomain> <20090204221121.GD10229@movementarian.org> <20090205004157.GC6794@localdomain> <20090205132529.GA12132@csn.ul.ie> <20090205190851.GA6692@localdomain> <20090205233257.GH10229@movementarian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090205233257.GH10229@movementarian.org>
Sender: owner-linux-mm@kvack.org
To: wli@movementarian.org
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2009 at 06:32:57PM -0500, wli@movementarian.org wrote:
>On Thu, Feb 05, 2009 at 11:08:51AM -0800, Ravikiran G Thirumalai wrote:
>> I totally agree.  In fact yesterday I was thinking of resending
>> this patch to not account for shm memory when a user is not
>> validated against rlimits (when he has CAP_IPC_LOCK or if he
>> belongs to the sysctl_hugetlb_shm_group).
>> As I see it there must be two parts:
>> 1. Free ticket to CAP_IPC_LOCK and users belonging to
>>    sysctl_hugetlb_shm_group
>> 2. Patch to have users not having CAP_IPC_LOCK or
>>    sysctl_hugetlb_shm_group to check against memlock
>>    rlimits, and account it.  Also mark this deprecated in
>>    feature-removal-schedule.txt
>> Would this be OK?
>
>This is the ideal scenario, except I thought the rlimit was destined
>to replace the other methods, not vice-versa. I don't really mind
>going this way, but maybe we should check in with the rlimit authors.

RLIMIT_MEMLOCK for SHM_HUGETLB seems bad and unrelated!  And as Mel rightly
pointed out,  currently rlimits are checked for hugetlb shm but not for
hugetlb mmaps.  Unless whoever authored the rlimit limitation comes forward
with a good explanation, I think it should be deprecated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
