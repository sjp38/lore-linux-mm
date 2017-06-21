Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A00B06B0430
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:54:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p4so165233099pfk.15
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:54:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g34si14540163pld.495.2017.06.21.10.54.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 10:54:04 -0700 (PDT)
Date: Wed, 21 Jun 2017 10:54:03 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Message-ID: <20170621175403.n5kssz32e2oizl7k@intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 21, 2017 at 02:12:27AM +0000, Naoya Horiguchi wrote:

> We had better have a reverse operation of this to cancel the unmapping
> when unpoisoning?

When we have unpoisoning, we can add something.  We don't seem to have
an inverse function for "set_memory_np" to just flip the _PRESENT bit
back on again. But it would be trivial to write a set_memory_pp().

Since we'd be doing this after the poison has been cleared, we wouldn't
need to play games with the address.  We'd just use:

	set_memory_pp((unsigned long)pfn_to_kaddr(pfn), 1);

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
