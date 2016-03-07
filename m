Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 60E796B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 11:45:27 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 129so38427938pfw.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 08:45:27 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id l9si29869191pfb.158.2016.03.07.08.45.26
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 08:45:26 -0800 (PST)
Date: Mon, 07 Mar 2016 11:45:21 -0500 (EST)
Message-Id: <20160307.114521.1646726145228714690.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <56DD9949.1000106@oracle.com>
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
	<20160305.230702.1325379875282120281.davem@davemloft.net>
	<56DD9949.1000106@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Mon, 7 Mar 2016 08:07:53 -0700

> I can remove CONFIG_SPARC_ADI. It does mean this code will be built
> into 32-bit kernels as well but it will be inactive code.

The code should be built only into obj-$(CONFIG_SPARC64) just like the
rest of the 64-bit specific code.  I don't know why in the world you
would build it into the 32-bit kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
