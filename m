Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 403916B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 01:05:15 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f73so2248832yha.17
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 22:05:14 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id r4si9353122yhg.85.2014.01.21.22.05.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 22:05:13 -0800 (PST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Tue, 21 Jan 2014 23:05:12 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B4DCE19D803E
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 23:05:00 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0M42iJ49306452
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 05:02:44 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0M659Sw024051
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 23:05:09 -0700
Date: Wed, 22 Jan 2014 14:05:06 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] restore user defined min_free_kbytes when disabling thp
Message-ID: <20140122060506.GA2657@localhost.localdomain>
References: <20140121093859.GA7546@localhost.localdomain>
 <20140121102351.GD4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140121102351.GD4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

On Tue, Jan 21, 2014 at 10:23:51AM +0000, Mel Gorman wrote:
> On Tue, Jan 21, 2014 at 05:38:59PM +0800, Han Pingtian wrote:
> > The testcase 'thp04' of LTP will enable THP, do some testing, then
> > disable it if it wasn't enabled. But this will leave a different value
> > of min_free_kbytes if it has been set by admin. So I think it's better
> > to restore the user defined value after disabling THP.
> > 
> 
> Then have LTP record what min_free_kbytes was at the same time THP was
> enabled by the test and restore both settings. It leaves a window where
> an admin can set an alternative value during the test but that would also
> invalidate the test in same cases and gets filed under "don't do that".
> 

Because the value is changed in kernel, so it would be better to 
restore it in kernel, right? :)  I have a v2 patch which will restore
the value only if it isn't set again by user after THP's initialization.
This v2 patch is dependent on the patch 'mm: show message when updating
min_free_kbytes in thp' which has been added to -mm tree, can be found
here:

http://ozlabs.org/~akpm/mmotm/broken-out/mm-show-message-when-updating-min_free_kbytes-in-thp.patch

please have a look. Thanks.
