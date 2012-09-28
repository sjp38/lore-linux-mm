Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id DC14E6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 12:26:32 -0400 (EDT)
Date: Fri, 28 Sep 2012 16:26:31 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/3] sl[au]b: process slabinfo_show in common code
In-Reply-To: <1348844608-12568-4-git-send-email-glommer@parallels.com>
Message-ID: <0000013a0db36047-406edc2f-5adb-4e50-86ba-a398be3a43e1-000000@email.amazonses.com>
References: <1348844608-12568-1-git-send-email-glommer@parallels.com> <1348844608-12568-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> [ v2: moved objects_per_slab and cache_order to slabinfo ]

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
