Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03ED96B6A70
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 19:33:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e15-v6so925835pfi.5
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 16:33:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j5-v6si16855749pgg.293.2018.09.03.16.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 16:33:13 -0700 (PDT)
Date: Mon, 3 Sep 2018 16:33:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] userfaultfd: allow
 get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) to trigger userfaults
Message-Id: <20180903163312.4d758536e1208f8927d886e9@linux-foundation.org>
In-Reply-To: <20180831214848.23676-1-aarcange@redhat.com>
References: <20180831214848.23676-1-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Maxime Coquelin <maxime.coquelin@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Fri, 31 Aug 2018 17:48:48 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:

> get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) called a get_user_pages that
> would not be waiting for userfaults before failing and it would hit on
> a SIGBUS instead. Using get_user_pages_locked/unlocked instead will
> allow get_mempolicy to allow userfaults to resolve the fault and fill
> the hole, before grabbing the node id of the page.

What is the userspace visible impact of this change?
