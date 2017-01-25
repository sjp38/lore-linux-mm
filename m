Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A42286B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:36:01 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d185so285901457pgc.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:36:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 82si24738126pge.77.2017.01.25.14.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:36:00 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PMXZC4092265
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:35:59 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2874nkrgq3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:35:59 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 25 Jan 2017 15:35:58 -0700
Date: Wed, 25 Jan 2017 14:35:56 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
Reply-To: paulmck@linux.vnet.ibm.com
References: <20170118110731.GA15949@linux.vnet.ibm.com>
 <20170125202533.GA22138@cmpxchg.org>
 <a4cb93f8-0ca4-57aa-f395-1b22143a32bd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4cb93f8-0ca4-57aa-f395-1b22143a32bd@suse.cz>
Message-Id: <20170125223555.GM3989@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, Jan 25, 2017 at 10:26:08PM +0100, Vlastimil Babka wrote:
> On 01/25/2017 09:25 PM, Johannes Weiner wrote:
> >On Wed, Jan 18, 2017 at 03:07:32AM -0800, Paul E. McKenney wrote:
> >>A group of Linux kernel hackers reported chasing a bug that resulted
> >>from their assumption that SLAB_DESTROY_BY_RCU provided an existence
> >>guarantee, that is, that no block from such a slab would be reallocated
> >>during an RCU read-side critical section.  Of course, that is not the
> >>case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
> >>slab of blocks.
> >>
> >>However, there is a phrase for this, namely "type safety".  This commit
> >>therefore renames SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU in order
> >>to avoid future instances of this sort of confusion.
> >>
> >>Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >
> >This has come up in the past, and it always proved hard to agree on a
> >better name for it. But I like SLAB_TYPESAFE_BY_RCU the best out of
> >all proposals, and it's much more poignant than the current name.
> 
> Heh, until I've seen this thread I had the same wrong assumption
> about the flag, so it suprised me. Good thing I didn't have a chance
> to use it wrongly so far :)
> 
> "Type safety" in this context seems quite counter-intuitive for me,
> as I've only heard it to describe programming languages. But that's
> fine when the name sounds so exotic that one has to look up what it
> does. Much safer than when the meaning seems obvious, but in fact
> it's misleading.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> >Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thank you both!  I have added these, as well as a Not-acked-by
for Eric.  ;-)

							Thanx, Paul

> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
