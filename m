Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8086C6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:39:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n88so15508989wrb.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:39:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j19si3377529wmi.144.2017.08.17.14.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 14:39:21 -0700 (PDT)
Date: Thu, 17 Aug 2017 14:39:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Message-Id: <20170817143916.63fca76e4c1fd841e0afd4cf@linux-foundation.org>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, 16 Aug 2017 20:05:29 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:

> Heterogeneous Memory Management (HMM) (description and justification)

The patchset adds 55 kbytes to x86_64's mm/*.o and there doesn't appear
to be any way of avoiding this overhead, or of avoiding whatever
runtime overheads are added.

It also adds 18k to arm's mm/*.o and arm doesn't support HMM at all.

So that's all quite a lot of bloat for systems which get no benefit from
the patchset.  What can we do to improve this situation (a lot)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
