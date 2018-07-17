Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6594A6B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:46:46 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id cf17-v6so1204423plb.2
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:46:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62-v6sor477870pft.105.2018.07.17.13.46.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 13:46:45 -0700 (PDT)
Date: Tue, 17 Jul 2018 13:46:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and
 movable_core=
In-Reply-To: <20180717131837.18411-1-bhe@redhat.com>
Message-ID: <alpine.DEB.2.21.1807171344320.12251@chino.kir.corp.google.com>
References: <20180717131837.18411-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org

On Tue, 17 Jul 2018, Baoquan He wrote:

> We can still use 'kernelcore=mirror' or 'movable_node' for the usage
> of hotplug and movable zone. If somebody shows up with a valid usecase
> we can reconsider.
> 

We actively use kernelcore=n%, I had recently added support for the option 
in the first place in 4.17.  It's certainly not deprecated.

commit a5c6d6509342785bef53bf9508e1842b303f1878
Author: David Rientjes <rientjes@google.com>
Date:   Thu Apr 5 16:23:09 2018 -0700

    mm, page_alloc: extend kernelcore and movablecore for percent
