Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 772BD6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 14:16:05 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj10so83756247pad.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 11:16:05 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ey12si4380794pac.203.2016.03.07.11.16.04
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 11:16:04 -0800 (PST)
Date: Mon, 07 Mar 2016 14:16:00 -0500 (EST)
Message-Id: <20160307.141600.1873883635480850431.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <56DDC776.3040003@oracle.com>
References: <56DDC2B6.6020009@oracle.com>
	<56DDC3EB.8060909@oracle.com>
	<56DDC776.3040003@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: rob.gardner@oracle.com, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Mon, 7 Mar 2016 11:24:54 -0700

> Tags can be cleared by user by setting tag to 0. Tags are
> automatically cleared by the hardware when the mapping for a virtual
> address is removed from TSB (which is why swappable pages are a
> problem), so kernel does not have to do it as part of clean up.

You might be able to crib some bits for the Tag in the swp_entry_t, it's
64-bit and you can therefore steal bits from the offset field.

That way you'll have the ADI tag in the page tables, ready to re-install
at swapin time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
