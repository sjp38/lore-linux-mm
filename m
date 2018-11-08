Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 350846B063C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 14:24:39 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g24-v6so18834357pfi.23
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 11:24:39 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id g13si4188693pgk.165.2018.11.08.11.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 11:24:37 -0800 (PST)
Date: Thu, 8 Nov 2018 12:24:35 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181108122435.65eceefe@lwn.net>
In-Reply-To: <20181108191553.nu7yn2akmcql2vje@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
	<20181105165558.11698-2-daniel.m.jordan@oracle.com>
	<20181108102638.3415ae0b@lwn.net>
	<20181108191553.nu7yn2akmcql2vje@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz, peterz@infradead.org, dhaval.giani@oracle.com

On Thu, 8 Nov 2018 11:15:53 -0800
Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> > - You have kerneldoc comments for the API functions, but you don't pull
> >   those into the documentation itself.  Adding some kernel-doc directives
> >   could help to fill things out nicely with little effort.  
> 
> I thought this part of ktask.rst handled that, or am I not doing it right?
> 
>     Interface
>     =========
>     
>     .. kernel-doc:: include/linux/ktask.h

Sigh, no, you're doing it just fine, and I clearly wasn't sufficiently
caffeinated.  Apologies for the noise.

jon
