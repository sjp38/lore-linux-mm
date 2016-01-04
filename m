Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 11C496B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 13:29:42 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so160924801pff.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:29:42 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z12si55570469pas.77.2016.01.04.10.29.41
        for <linux-mm@kvack.org>;
        Mon, 04 Jan 2016 10:29:41 -0800 (PST)
Date: Mon, 4 Jan 2016 13:29:39 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: pagewalk API
Message-ID: <20160104182939.GA27351@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


I find myself in the position of needing to expand the pagewalk API to
allow PUDs to be passed to pagewalk handlers.

The problem with the current pagewalk API is that it requires the callers
to implement a lot of boilerplate, and the further up the hierarchy we
intercept the pagewalk, the more boilerplate has to be implemented in each
caller, to the point where it's not worth using the pagewalk API any more.

Compare and contrast mincore's pud_entry that only has to handle PUDs
which are guaranteed to be (1) present, (2) huge, (3) locked versus the
PMD code which has to take care of checking all three things itself.

(http://marc.info/?l=linux-mm&m=145097405229181&w=2)

Kirill's point is that it's confusing to have the PMD and PUD handling
be different, and I agree.  But it certainly saves a lot of code in the
callers.  So should we convert the PMD code to be similar?  Or put a
subptimal API in for the PUD case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
