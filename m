Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8BF36B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:22:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y8-v6so1705322pfl.17
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:22:08 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v190-v6si2504007pfv.48.2018.06.20.08.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 08:22:07 -0700 (PDT)
Subject: Re: [PATCH v13 24/24] selftests/vm: test correct behavior of pkey-0
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-25-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0a7c79a9-8d2d-09cb-30c6-f0f7bca526db@intel.com>
Date: Wed, 20 Jun 2018 08:22:05 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-25-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/13/2018 05:45 PM, Ram Pai wrote:
> Ensure pkey-0 is allocated on start.  Ensure pkey-0 can be attached
> dynamically in various modes, without failures.  Ensure pkey-0 can be
> freed and allocated.

I like this.  Looks very useful.

Acked-by: Dave Hansen <dave.hansen@intel.com>
