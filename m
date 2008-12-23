Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4C77C6B0044
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 08:00:47 -0500 (EST)
Date: Tue, 23 Dec 2008 15:00:43 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] failslab for SLUB
In-Reply-To: <20081223103616.GA7217@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0812231459580.18017@melkki.cs.Helsinki.FI>
References: <20081223103616.GA7217@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Akinobu,

On Tue, 23 Dec 2008, Akinobu Mita wrote:
> Currently fault-injection capability for SLAB allocator is only available
> to SLAB. This patch makes it available to SLUB, too.

The code duplication in your patch is unfortunate. What do you think of 
this patch instead?

		Pekka
