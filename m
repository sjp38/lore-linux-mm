Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF746B000C
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:35:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x81so5318200pgx.21
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:35:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a2-v6si6874331plp.544.2018.03.16.15.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:35:01 -0700 (PDT)
Subject: Re: [PATCH v12 22/22] selftests/vm: Fix deadlock in protection_keys.c
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-23-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0c82a148-3f10-66f4-a7d7-cace557ff038@intel.com>
Date: Fri, 16 Mar 2018 15:34:52 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-23-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
> 
> The sig_chld() handler calls dprintf2() taking care of setting
> dprint_in_signal so that sigsafe_printf() won't call printf().
> Unfortunately, this precaution is is negated by dprintf_level(), which
> has a call to fflush().
> 
> This function acquires a lock, which means that if the signal interrupts an
> ongoing fflush() the process will deadlock. At least on powerpc this is
> easy to trigger, resulting in the following backtrace when attaching to the
> frozen process:

Ugh, yeah, I've run into this too.

Acked-by: Dave Hansen <dave.hansen@intel.com>
