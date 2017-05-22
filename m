Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC67831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 12:36:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c15so93433839ith.7
        for <linux-mm@kvack.org>; Mon, 22 May 2017 09:36:04 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id d134si114381ith.53.2017.05.22.09.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 09:36:03 -0700 (PDT)
Date: Mon, 22 May 2017 11:35:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170519134934.0c298882@redhat.com>
Message-ID: <alpine.DEB.2.20.1705221134540.11040@east.gentwo.org>
References: <20170502131527.7532fc2e@redhat.com> <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org> <20170512122704.GA30528@amt.cnet> <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org> <20170512154026.GA3556@amt.cnet> <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet> <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org> <20170515191531.GA31483@amt.cnet> <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org> <20170519143407.GA19282@amt.cnet> <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
 <20170519134934.0c298882@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, 19 May 2017, Luiz Capitulino wrote:

> Something that crossed my mind was to add a new tunable to set
> the vmstat_interval for each CPU, this way we could essentially
> disable it to the CPUs where DPDK is running. What's the implications
> of doing this besides not getting up to date stats in /proc/vmstat
> (which I still have to confirm would be OK)? Can this break anything
> in the kernel for example?

The data is still going to be updated when the differential gets to big.

Increasing the vmstat interval and reducing the differential threshold
would get your there....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
