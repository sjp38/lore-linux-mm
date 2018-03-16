Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18C466B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:32:48 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 60-v6so6256609plf.19
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:32:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1-v6si6797144plz.254.2018.03.16.15.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:32:47 -0700 (PDT)
Subject: Re: [PATCH v12 20/22] selftests/vm: testcases must restore
 pkey-permissions
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-21-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6f45e32f-a18c-9b33-efaa-aab3c095720f@intel.com>
Date: Fri, 16 Mar 2018 15:32:38 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-21-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> Generally the signal handler restores the state of the pkey register
> before returning. However there are times when the read/write operation
> can legitamely fail without invoking the signal handler.  Eg: A
> sys_read() operaton to a write-protected page should be disallowed.  In
> such a case the state of the pkey register is not restored to its
> original state.  The test case is responsible for restoring the key
> register state to its original value.

Oh, that's a good point.

Could we just do this in a common place, though?  Like reset the
register after each test?  Seems more foolproof.
