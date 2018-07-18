Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4B16B026E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:27:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d1-v6so2477328pfo.16
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:27:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x19-v6si3291048plr.15.2018.07.18.08.27.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:27:11 -0700 (PDT)
Subject: Re: [PATCH v14 04/22] selftests/vm: move arch-specific definitions to
 arch-specific header
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-5-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cbe905d6-bff5-cbe0-831b-13c76334ff1a@intel.com>
Date: Wed, 18 Jul 2018 08:27:08 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-5-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> In preparation for multi-arch support, move definitions which have
> arch-specific values to x86-specific header.

Acked-by: Dave Hansen <dave.hansen@intel.com>
