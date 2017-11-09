Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 777F9440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 17:23:43 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id q33so2846251qta.18
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 14:23:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t126si2109405qkc.467.2017.11.09.14.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 14:23:42 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA9MNMsG124055
	for <linux-mm@kvack.org>; Thu, 9 Nov 2017 17:23:41 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e4y3h9u8u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Nov 2017 17:23:40 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 9 Nov 2017 17:23:39 -0500
Date: Thu, 9 Nov 2017 14:23:29 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 00/51] powerpc, mm: Memory Protection Keys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <87efpbm706.fsf@mid.deneb.enyo.de>
 <20171107012218.GA5546@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107012218.GA5546@ram.oc3035372033.ibm.com>
Message-Id: <20171109222329.GB5656@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Mon, Nov 06, 2017 at 05:22:18PM -0800, Ram Pai wrote:
> On Mon, Nov 06, 2017 at 10:28:41PM +0100, Florian Weimer wrote:
> > * Ram Pai:
> > 
> > > Testing:
> > > -------
> > > This patch series has passed all the protection key
> > > tests available in the selftest directory.The
> > > tests are updated to work on both x86 and powerpc.
> > > The selftests have passed on x86 and powerpc hardware.
> > 
....snip....

> > What about siglongjmp from a signal handler?
> 
> On powerpc there is some relief.  the permissions on a key can be
> modified from anywhere, including from the signal handler, and the
> effect will be immediate.  You dont have to wait till the
> signal handler returns for the key permissions to be restore.
> 
> also after return from the sigsetjmp();
> possibly caused by siglongjmp(), the program can restore the permission
> on any key.
> 
> Atleast that is my theory. Can you give me a testcase; if you have one
> handy.
> 
> > 
> >   <https://sourceware.org/bugzilla/show_bug.cgi?id=22396>
> > 

reading through the bug report, you mention that the following
"The application may not be able to save and restore the protection bits
for all keys because the kernel API does not actually specify that the
set of keys is a small, fixed set."

What exact kernel API do you need? This patch set exposes the total
number of keys and  max keys,  through sysfs.
https://marc.info/?l=linux-kernel&m=150995950219669&w=2

Is this sufficient? or do you need something else?

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
