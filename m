Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5907F6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 09:42:37 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f10so1305182qtc.0
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 06:42:37 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [69.252.207.40])
        by mx.google.com with ESMTPS id w73si1407118qkb.483.2018.04.11.06.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 06:42:36 -0700 (PDT)
Date: Wed, 11 Apr 2018 08:41:33 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: reschedule cache_reap() on the same CPU
In-Reply-To: <71010251-e1bc-e934-cecf-ae37a1cede90@iki.fi>
Message-ID: <alpine.DEB.2.20.1804110841040.3763@nuc-kabylake>
References: <20180410081531.18053-1-vbabka@suse.cz> <20180411070007.32225-1-vbabka@suse.cz> <71010251-e1bc-e934-cecf-ae37a1cede90@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

On Wed, 11 Apr 2018, Pekka Enberg wrote:

> Acked-by: Pekka Enberg <penberg@kernel.org>

Good to hear from you again.

Acked-by: Christoph Lameter <cl@linux.com>
