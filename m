Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5DC06B0010
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:30:59 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id k4-v6so6257250pls.15
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:30:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1-v6si7119117pln.656.2018.03.16.15.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:30:58 -0700 (PDT)
Subject: Re: [PATCH v12 18/22] selftests/vm: associate key on a mapped page
 and detect write violation
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-19-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cf9ccf32-724c-e25c-4226-3c9c670bc4aa@intel.com>
Date: Fri, 16 Mar 2018 15:30:50 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-19-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> detect write-violation on a page to which write-disabled
> key is associated much after the page is mapped.

The more tests the merrier.

Acked-by: Dave Hansen <dave.hansen@intel.com>
