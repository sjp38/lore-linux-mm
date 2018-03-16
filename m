Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1F6B6B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:31:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x7so5869456pfd.19
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:31:37 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 79si5638326pga.647.2018.03.16.15.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:31:36 -0700 (PDT)
Subject: Re: [PATCH v12 19/22] selftests/vm: detect write violation on a
 mapped access-denied-key page
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-20-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f0468b51-6c2a-0317-2c5e-d48d8a12c374@intel.com>
Date: Fri, 16 Mar 2018 15:31:28 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-20-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> detect write-violation on a page to which access-disabled
> key is associated much after the page is mapped.

Acked-by: Dave Hansen <dave.hansen@intel.com>
