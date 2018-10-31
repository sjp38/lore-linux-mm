Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEE56B02BE
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:20:22 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z17-v6so12792816iol.20
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:20:22 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z5si12340043itj.59.2018.10.30.20.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Oct 2018 20:20:21 -0700 (PDT)
Subject: Re: mmotm 2018-10-30-16-08 uploaded (arch/x86/kernel/vsmp_64.c)
References: <20181030230905.xHZmM%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9e14d183-55a4-8299-7a18-0404e50bf004@infradead.org>
Date: Tue, 30 Oct 2018 20:20:09 -0700
MIME-Version: 1.0
In-Reply-To: <20181030230905.xHZmM%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Ravikiran Thirumalai <kiran@scalemp.com>, Shai Fultheim <shai@scalemp.com>, X86 ML <x86@kernel.org>

On 10/30/18 4:09 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-10-30-16-08 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.


Build error on x86_64 from origin.patch (i.e., not mmotm)
when CONFIG_PCI is not enabled:
Oh:  CONFIG_X86_VSMP is also not enabled, but
arch/x86/kernel/Makefile always tries to build vsmp_64.o.


ld: arch/x86/kernel/vsmp_64.o: in function `vsmp_cap_cpus':
vsmp_64.c:(.init.text+0x1e): undefined reference to `read_pci_config'


-- 
~Randy
