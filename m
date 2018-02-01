Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1276B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 21:55:35 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f1so2417704plb.7
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:55:35 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id i9-v6si837506plt.544.2018.01.31.18.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jan 2018 18:55:25 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v11 0/3] mm, x86, powerpc: Enhancements to Memory Protection Keys.
In-Reply-To: <20180131070711.pad45qmnougnh4vf@gmail.com>
References: <1517341452-11924-1-git-send-email-linuxram@us.ibm.com> <20180131070711.pad45qmnougnh4vf@gmail.com>
Date: Thu, 01 Feb 2018 13:55:21 +1100
Message-ID: <87lggde7vq.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Ram Pai <linuxram@us.ibm.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

Ingo Molnar <mingo@kernel.org> writes:

> * Ram Pai <linuxram@us.ibm.com> wrote:
>
>> This patch series provides arch-neutral enhancements to
>> enable memory-keys on new architecutes, and the corresponding
>> changes in x86 and powerpc specific code to support that.
>> 
>> a) Provides ability to support upto 32 keys.  PowerPC
>> 	can handle 32 keys and hence needs this.
>> 
>> b) Arch-neutral code; and not the arch-specific code,
>>    determines the format of the string, that displays the key
>>    for each vma in smaps.
>> 
>> PowerPC implementation of memory-keys is now in powerpc/next tree.
>> https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git/commit/?h=next&id=92e3da3cf193fd27996909956c12a23c0333da44
>
> All three patches look sane to me. If you would like to carry these generic bits 
> in the PowerPC tree as well then:
>
>   Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks.

I'll put them in powerpc next and probably send to Linus next week in a
2nd pull request for 4.16.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
