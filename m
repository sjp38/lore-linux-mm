Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 10A0D6B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 14:19:56 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x188so60901969pfb.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 11:19:56 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id x6si6512276pas.72.2016.03.07.11.19.55
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 11:19:55 -0800 (PST)
Date: Mon, 07 Mar 2016 14:19:50 -0500 (EST)
Message-Id: <20160307.141950.2225098078054843052.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <CALCETrU5NCzh3b7We8903G0_Tm-oycgP3+gS9fG+vC_rdgTddw@mail.gmail.com>
References: <CALCETrXN43nT4zq2MpO90VrgK3k+DKHjOHWf7iOhS7TSBmdCPQ@mail.gmail.com>
	<56DDC6E0.4000907@oracle.com>
	<CALCETrU5NCzh3b7We8903G0_Tm-oycgP3+gS9fG+vC_rdgTddw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: luto@amacapital.net
Cc: khalid.aziz@oracle.com, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 7 Mar 2016 10:49:57 -0800

> What data structure or structures changes when this stxa instruction happens?

An internal table, maintained by the CPU and/or hypervisor, and if in physical
addresses then in a region which is only accessible by the hypervisor.

The table is not accessible by the kernel at all via loads or stores.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
