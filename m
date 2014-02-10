Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id B89D86B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 03:23:21 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id ii20so8908060qab.5
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 00:23:21 -0800 (PST)
Received: from e7.ny.us.ibm.com (e7.ny.us.ibm.com. [32.97.182.137])
        by mx.google.com with ESMTPS id c6si9536610qad.169.2014.02.10.00.23.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 00:23:21 -0800 (PST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 10 Feb 2014 03:23:20 -0500
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6DE6A6E803A
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 03:23:14 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1A8NIKM7733712
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 08:23:19 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1A8NIHt009476
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 03:23:18 -0500
Date: Mon, 10 Feb 2014 13:59:32 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V5 RESEND] mm readahead: Fix readahead fail for no
 local memory and limit readahead pages
Message-ID: <20140210082931.GA25323@linux.vnet.ibm.com>
Reply-To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, nacc@linux.vnet.ibm.com

* Andrew Morton <akpm@linux-foundation.org> [2014-02-06 14:51:05]:

> On Wed, 22 Jan 2014 16:23:45 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
> 
> 
> Looks reasonable to me.  Please send along a fixed up changelog.
> 

Hi Andrew,
Sorry took some time to get and measure benefit on the memoryless system.
Resending patch with changelog and comment changes based on your and
David's suggestion.

----8<--- 
