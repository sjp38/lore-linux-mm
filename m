Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B48436B061D
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 12:26:41 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g76-v6so4395683pfe.13
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 09:26:41 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id w187si4143631pgb.552.2018.11.08.09.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 09:26:40 -0800 (PST)
Date: Thu, 8 Nov 2018 10:26:38 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181108102638.3415ae0b@lwn.net>
In-Reply-To: <20181105165558.11698-2-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
	<20181105165558.11698-2-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon,  5 Nov 2018 11:55:46 -0500
Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> Motivates and explains the ktask API for kernel clients.

A couple of quick thoughts:

- Agree with Peter on the use of "task"; something like "job" would be far
  less likely to create confusion.  Maybe you could even call it a "batch
  job" to give us old-timers warm fuzzies...:)

- You have kerneldoc comments for the API functions, but you don't pull
  those into the documentation itself.  Adding some kernel-doc directives
  could help to fill things out nicely with little effort.

Thanks,

jon
