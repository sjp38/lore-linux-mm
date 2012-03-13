Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id BB7EC6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 04:19:56 -0400 (EDT)
Date: Tue, 13 Mar 2012 01:16:33 -0700 (PDT)
Message-Id: <20120313.011633.151968036751263435.davem@davemloft.net>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAHqTa-2c7pOTicWO8stNJfVfep4gSPHwKdr3kv_Jk-oi=dU5bw@mail.gmail.com>
References: <CAHqTa-3sMRJ0p7driNF+d=f_NZNCF-+TWnCSNO2efEdfv0ayVQ@mail.gmail.com>
	<20120313.001842.1454669292182923878.davem@davemloft.net>
	<CAHqTa-2c7pOTicWO8stNJfVfep4gSPHwKdr3kv_Jk-oi=dU5bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: apenwarr@gmail.com
Cc: akpm@linux-foundation.org, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, a.p.zijlstra@chello.nl, fdinitto@redhat.com, hannes@cmpxchg.org, olaf@aepfle.de, paul.gortmaker@windriver.com, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 04:10:42 -0400

> On Tue, Mar 13, 2012 at 3:18 AM, David Miller <davem@davemloft.net> wrote:
>> I'm only saying that you should design your stuff such that an
>> architecture with such features could easily hook into it using this
>> kind facility.
> 
> How about this?

Function signature looks good.

But on a platform with firmware based memory retaining facilitites
we're going to need to invoke this way before bootmem or memblocks are
even setup, because the retain call influences the free memory lists
that the firmware gives to us and those free memory lists are what we
use to populate the memblock tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
