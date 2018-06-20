Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC7AF6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:17:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n19-v6so1704501pff.8
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:17:11 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m6-v6si2259784pgm.306.2018.06.20.08.17.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 08:17:10 -0700 (PDT)
Subject: Re: [PATCH v13 19/24] selftests/vm: associate key on a mapped page
 and detect access violation
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-20-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <048b1de9-85f8-22ff-a31a-b06a382769bb@intel.com>
Date: Wed, 20 Jun 2018 08:16:44 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-20-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/13/2018 05:45 PM, Ram Pai wrote:
> +void test_read_of_access_disabled_region_with_page_already_mapped(int *ptr,
> +		u16 pkey)
> +{
> +	int ptr_contents;
> +
> +	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n",
> +				pkey, ptr);
> +	ptr_contents = read_ptr(ptr);
> +	dprintf1("reading ptr before disabling the read : %d\n",
> +			ptr_contents);
> +	read_pkey_reg();
> +	pkey_access_deny(pkey);
> +	ptr_contents = read_ptr(ptr);
> +	dprintf1("*ptr: %d\n", ptr_contents);
> +	expected_pkey_fault(pkey);
> +}

Looks fine to me.  I'm a bit surprised we didn't do this already, which
is a good thing for this patch.

FWIW, if you took patches like this and put them first, you could
probably get it merged now.  Yes, I know it would mean redoing some of
the later code move and rename ones.
