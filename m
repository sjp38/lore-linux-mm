Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0C296B000C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:56:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u8-v6so869833pfn.18
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:56:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r65-v6si1466557pfe.298.2018.07.17.10.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 10:56:39 -0700 (PDT)
Subject: Re: [PATCH v13 19/24] selftests/vm: associate key on a mapped page
 and detect access violation
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-20-git-send-email-linuxram@us.ibm.com>
 <048b1de9-85f8-22ff-a31a-b06a382769bb@intel.com>
 <20180717161332.GH5790@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <febe6668-c66a-4601-63da-44501faf12ee@intel.com>
Date: Tue, 17 Jul 2018 10:56:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180717161332.GH5790@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 09:13 AM, Ram Pai wrote:
> I have incorporated almost all of your comments. But there are some
> comments that take some effort to implement. Shall we get the patches
> merged in the current form?  This code has been sitting out for a while.
> 
> In the current form its tested and works on powerpc and on x86, and
> incorporates about 95% of your suggestions. The rest I will take care
> as we go.

What constitutes the remaining 5%?
