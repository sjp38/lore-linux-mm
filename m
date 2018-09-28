Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0DD28E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 10:20:12 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x204-v6so6127835qka.6
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:20:12 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id x33-v6si878950qtk.221.2018.09.28.07.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Sep 2018 07:20:11 -0700 (PDT)
Date: Fri, 28 Sep 2018 14:20:11 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3] slub: extend slub debug to handle multiple slabs
In-Reply-To: <20180928111139.27962-1-atomlin@redhat.com>
Message-ID: <01000166208d1f55-2b13fdf8-a1a5-4a64-80f2-2e1a5314285e-000000@email.amazonses.com>
References: <20180928111139.27962-1-atomlin@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, malchev@google.com

On Fri, 28 Sep 2018, Aaron Tomlin wrote:

> Extend the slub_debug syntax to "slub_debug=<flags>[,<slub>]*", where <slub>
> may contain an asterisk at the end.  For example, the following would poison
> all kmalloc slabs:

Acked-by: Christoph Lameter <cl@linux.com>
