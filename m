Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD1946B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 21:50:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m82so42657937pfk.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 18:50:18 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id v26si543583pgn.268.2017.06.27.18.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Jun 2017 18:50:17 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v4 17/17] procfs: display the protection-key number associated with a vma
In-Reply-To: <1498558319-32466-18-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com> <1498558319-32466-18-git-send-email-linuxram@us.ibm.com>
Date: Wed, 28 Jun 2017 11:50:13 +1000
Message-ID: <87d19odgoa.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Ram Pai <linuxram@us.ibm.com> writes:

> Display the pkey number associated with the vma in smaps of a task.
> The key will be seen as below:
>
> VmFlags: rd wr mr mw me dw ac key=0

Why wouldn't we just emit a "ProtectionKey:" line like x86 does?

See their arch_show_smap().

You should probably also do what x86 does, which is to not display the
key on CPUs that don't support keys.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
