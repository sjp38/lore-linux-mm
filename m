Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64C2D6B026A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:26:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n17-v6so2264620pff.17
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:26:20 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id u24-v6si3496627pgk.72.2018.07.18.08.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:26:19 -0700 (PDT)
Subject: Re: [PATCH v14 03/22] selftests/vm: move generic definitions to
 header file
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-4-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7b7e20f1-a145-949a-1cbc-cca3e36631a6@intel.com>
Date: Wed, 18 Jul 2018 08:26:16 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-4-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

Acked-by: Dave Hansen <dave.hansen@intel.com>
