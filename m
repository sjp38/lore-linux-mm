Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9A856B000D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 14:59:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e10so2015714pff.3
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:59:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d8si2269446pgt.246.2018.03.14.11.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 11:59:32 -0700 (PDT)
Subject: Re: [PATCH 1/1 v2] x86: pkey-mprotect must allow pkey-0
References: <1521013574-27041-1-git-send-email-linuxram@us.ibm.com>
 <18b155e3-07e9-5a4b-1f95-e1667078438c@intel.com>
 <20180314171448.GA1060@ram.oc3035372033.ibm.com>
 <5027ca9e-63c8-47ab-960d-a9c4466d7075@intel.com>
 <20180314185452.GB1060@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3f7c9ee7-46db-723f-177d-7505d0ac1e41@intel.com>
Date: Wed, 14 Mar 2018 11:58:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180314185452.GB1060@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mingo@redhat.com, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On 03/14/2018 11:54 AM, Ram Pai wrote:
>>> (e) it bypasses key-permission checks when assigned.
>> I don't think this is necessary.  I think the only rule we *need* is:
>>
>> 	pkey-0 is allocated implicitly at execve() time.  You do not
>> 	need to call pkey_alloc() to allocate it.
> And can be explicitly associated with any address range ?

Yes, it should ideally be available for use just like any other key when
allocated.
