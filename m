Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF916B02F3
	for <linux-mm@kvack.org>; Thu, 11 May 2017 11:37:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o5so22716421ith.8
        for <linux-mm@kvack.org>; Thu, 11 May 2017 08:37:16 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id e20si504418ioj.1.2017.05.11.08.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 08:37:15 -0700 (PDT)
Date: Thu, 11 May 2017 10:37:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170502131527.7532fc2e@redhat.com>
Message-ID: <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org>
References: <20170425135717.375295031@redhat.com> <20170425135846.203663532@redhat.com> <20170502102836.4a4d34ba@redhat.com> <20170502165159.GA5457@amt.cnet> <20170502131527.7532fc2e@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Tue, 2 May 2017, Luiz Capitulino wrote:

> Ah, OK. Got this now. I'll give this patch a try. But I think we want
> to hear from Christoph (who worked on reducing the vmstat interruptions
> in the past).

A bit confused by this one. The vmstat worker is already disabled if there
are no updates. Also the patches by Chris Metcalf on data plane mode add a
prctl to quiet the vmstat workers.

Why do we need more than this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
