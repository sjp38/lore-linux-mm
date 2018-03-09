Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3181B6B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 15:00:43 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id x35so7609345qtx.5
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 12:00:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b4si1433580qkc.414.2018.03.09.12.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 12:00:39 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w29JuU6A083373
	for <linux-mm@kvack.org>; Fri, 9 Mar 2018 15:00:38 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gky5wuqhk-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Mar 2018 15:00:38 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 9 Mar 2018 20:00:35 -0000
Date: Fri, 9 Mar 2018 12:00:17 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
 <ec90ed75-2810-bcc3-8439-8dc85a6b46ac@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec90ed75-2810-bcc3-8439-8dc85a6b46ac@redhat.com>
Message-Id: <20180309200017.GR1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On Fri, Mar 09, 2018 at 12:04:49PM +0100, Florian Weimer wrote:
> On 03/09/2018 09:12 AM, Ram Pai wrote:
> >Once an address range is associated with an allocated pkey, it cannot be
> >reverted back to key-0. There is no valid reason for the above behavior.
> 
> mprotect without a key does not necessarily use key 0, e.g. if
> protection keys are used to emulate page protection flag combination
> which is not directly supported by the hardware.
> 
> Therefore, it seems to me that filtering out non-allocated keys is
> the right thing to do.

I am not sure, what you mean. Do you agree with the patch or otherwise?
RP
