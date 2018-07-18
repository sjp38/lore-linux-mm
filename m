Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F02E16B0266
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:25:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z21-v6so2756039plo.13
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:25:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d10-v6si3353483pgg.341.2018.07.18.08.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:25:42 -0700 (PDT)
Subject: Re: [PATCH v14 01/22] selftests/x86: Move protecton key selftest to
 arch neutral directory
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-2-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d37b2ac3-d5a7-19d3-e609-2a0ebbe980c4@intel.com>
Date: Wed, 18 Jul 2018 08:25:39 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-2-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

Acked-by: Dave Hansen <dave.hansen@intel.com>
