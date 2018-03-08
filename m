Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0EFB6B0009
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 13:25:35 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id o38so4911798qtj.9
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 10:25:35 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l24si20010124qtb.278.2018.03.08.10.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 10:25:34 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w28IOPsu050251
	for <linux-mm@kvack.org>; Thu, 8 Mar 2018 13:25:34 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gk843pgph-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Mar 2018 13:25:33 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 8 Mar 2018 18:25:31 -0000
Date: Thu, 8 Mar 2018 10:25:17 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: mm, x86, powerpc: pkey semantics for key-0 ?
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
 <1519257138-23797-4-git-send-email-linuxram@us.ibm.com>
 <2a7737cf-a5ba-c814-fdc7-45b5cdd47376@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a7737cf-a5ba-c814-fdc7-45b5cdd47376@intel.com>
Message-Id: <20180308182517.GO1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

Dave,

Is there a reason why the default key; key-0, is not allowed to be
explicitly associated with pages using pkey_mprotect()?

I see valid usecases where an application may initially want to
associate an address-range with some key and latter choose to revert to
its initial state, by associating key-0.  However our implementation
(both x86 and power) do not allow pkey_mprotect() to be called with
key-0.

I do not see a reason why it must be blocked.

Thoughts?
RP
