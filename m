Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id AAB046B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 22:59:54 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so1031013qcx.18
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 19:59:54 -0800 (PST)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id x4si35319152qad.28.2014.01.07.19.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 19:59:53 -0800 (PST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 22:59:53 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B0FD638C803B
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 22:59:50 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s083xo587930320
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 03:59:50 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s083xo5Y007004
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 22:59:50 -0500
Date: Wed, 8 Jan 2014 11:59:46 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140108035946.GI4106@localhost.localdomain>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106164604.GC27602@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Jan 06, 2014 at 05:46:04PM +0100, Michal Hocko wrote:
> On Sun 05-01-14 08:35:01, Han Pingtian wrote:
> [...]
> > From f4d085a880dfae7638b33c242554efb0afc0852b Mon Sep 17 00:00:00 2001
> > From: Han Pingtian <hanpt@linux.vnet.ibm.com>
> > Date: Fri, 3 Jan 2014 11:10:49 +0800
> > Subject: [PATCH] mm: show message when raising min_free_kbytes in THP
> > 
> > min_free_kbytes may be raised during THP's initialization. Sometimes,
> > this will change the value being set by user. Showing message will
> > clarify this confusion.
> 
> I do not have anything against informing about changing value
> set by user but this will inform also when the default value is
> updated. Is this what you want? Don't you want to check against
> user_min_free_kbytes? (0 if not set by user)
> 
But looks like the user can set min_free_kbytes to 0 by

    echo 0 > /proc/sys/vm/min_free_kbytes

and even set it to -1 the same way. So I think we need to restrict the
value of min_free_kbytes > 0 first?

> Btw. Do we want to restore the original value when khugepaged is
> disabled?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
