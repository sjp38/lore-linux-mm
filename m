Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3C858D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:43:55 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1OMO0Qm004673
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:24:00 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1OMhrpt282468
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:43:53 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1OMhrmv023597
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:43:53 -0500
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110224041851.GF31195@random.random>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
	 <1298425922-23630-9-git-send-email-andi@firstfloor.org>
	 <20110224041851.GF31195@random.random>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 24 Feb 2011 14:43:50 -0800
Message-ID: <1298587430.9138.24.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Thu, 2011-02-24 at 05:18 +0100, Andrea Arcangeli wrote:
> Incremental fix for your patch 8 (I doubt it was intentional).

Bah, sorry.  Should have read one more message down the thread. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
