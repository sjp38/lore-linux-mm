Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7223A6B0005
	for <linux-mm@kvack.org>; Sat, 10 Mar 2018 01:50:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v8so4820509pgs.9
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 22:50:38 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q61-v6si2301116plb.530.2018.03.09.22.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 22:50:37 -0800 (PST)
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
 <60886e4a-59d4-541a-a6af-d4504e6719ad@intel.com>
 <20180310055544.GU1060@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <842bd8a3-d869-f796-32ea-831427fefe4d@intel.com>
Date: Fri, 9 Mar 2018 22:50:33 -0800
MIME-Version: 1.0
In-Reply-To: <20180310055544.GU1060@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/09/2018 09:55 PM, Ram Pai wrote:
> On Fri, Mar 09, 2018 at 02:40:32PM -0800, Dave Hansen wrote:
>> On 03/09/2018 12:12 AM, Ram Pai wrote:
>>> Once an address range is associated with an allocated pkey, it cannot be
>>> reverted back to key-0. There is no valid reason for the above behavior.  On
>>> the contrary applications need the ability to do so.
>> Why don't we just set pkey 0 to be allocated in the allocation bitmap by
>> default?
> ok. that will make it allocatable. But it will not be associatable,
> given the bug in the current code. And what will be the
> default key associated with a pte? zero? or something else?

I'm just saying that I think we should try to keep from making it
special as much as possible.

Let's fix the bug that keeps it from being associatable.
