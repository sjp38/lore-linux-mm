Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F14F6B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 05:39:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n18so30745815pfe.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 02:39:54 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r6si19845192pgf.203.2016.10.25.02.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 02:39:53 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v4 3/5] powerpc/mm: allow memory hotplug into a memoryless node
In-Reply-To: <872f253d-8a55-246c-2be0-636a588e2dd0@gmail.com>
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com> <1475778995-1420-4-git-send-email-arbab@linux.vnet.ibm.com> <872f253d-8a55-246c-2be0-636a588e2dd0@gmail.com>
Date: Tue, 25 Oct 2016 20:39:45 +1100
Message-ID: <87pomoydge.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

Balbir Singh <bsingharora@gmail.com> writes:
> FYI, these checks were temporary to begin with
>
> I found this in git history
>
> b226e462124522f2f23153daff31c311729dfa2f (powerpc: don't add memory to empty node/zone)

Nice thanks for digging it up.

  commit b226e462124522f2f23153daff31c311729dfa2f
  Author:     Mike Kravetz <kravetz@us.ibm.com>
  AuthorDate: Fri Dec 16 14:30:35 2005 -0800
                                  ^^^^
                                  
That is why maintainers don't like to merge "temporary" patches :)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
