Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 92DB36B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 03:22:11 -0400 (EDT)
Date: Tue, 13 Mar 2012 00:18:42 -0700 (PDT)
Message-Id: <20120313.001842.1454669292182923878.davem@davemloft.net>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAHqTa-3sMRJ0p7driNF+d=f_NZNCF-+TWnCSNO2efEdfv0ayVQ@mail.gmail.com>
References: <CAHqTa-3DiZhd_yoRTzp2Np0Rp=_zrfL7CbN_twu+ZZeu7f4ENg@mail.gmail.com>
	<20120312.235002.344576347742686103.davem@davemloft.net>
	<CAHqTa-3sMRJ0p7driNF+d=f_NZNCF-+TWnCSNO2efEdfv0ayVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: apenwarr@gmail.com
Cc: akpm@linux-foundation.org, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, a.p.zijlstra@chello.nl, fdinitto@redhat.com, hannes@cmpxchg.org, olaf@aepfle.de, paul.gortmaker@windriver.com, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 03:14:21 -0400

> On Tue, Mar 13, 2012 at 2:50 AM, David Miller <davem@davemloft.net> wrote:
>> The idea is that you call prom_retain() before you take a look at what
>> physical memory is available in the kernel, and the firmware takes
>> this physical chunk out of those available memory lists upon
>> prom_retain() success.
> 
> This sounds like exactly the API I would have wanted, however:
> 
> 1) It's only available in arch/sparc so I can't test my patch if I try
> to use it;
> 2) There's nobody that calls it so it might not work;
> 3) I don't understand the API so I'm not really confident that
> reserving memory this way will actually prevent it from being seen by
> the kernel.
> 
> In short, I think I would screw it up.

I'm only saying that you should design your stuff such that an
architecture with such features could easily hook into it using this
kind facility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
