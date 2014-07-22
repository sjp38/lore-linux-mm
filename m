Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 834A36B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 21:20:10 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so3473245igb.4
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:20:10 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id 4si33110829igk.22.2014.07.21.18.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 18:20:09 -0700 (PDT)
Received: by mail-ig0-f174.google.com with SMTP id c1so3481634igq.1
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:20:09 -0700 (PDT)
Date: Mon, 21 Jul 2014 18:20:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
In-Reply-To: <53CDBB01.7040007@imgtec.com>
Message-ID: <alpine.DEB.2.02.1407211819340.9778@chino.kir.corp.google.com>
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com> <alpine.DEB.2.02.1407211754350.7042@chino.kir.corp.google.com> <53CDBB01.7040007@imgtec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org

On Mon, 21 Jul 2014, Leonid Yegoshin wrote:

> Yes, there is one, at least for MIPS. This stuff can be a common ground for
> both platforms (MIPS and XTENSA)
> 

Needs the mips patch as a followup as justification for the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
