Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 03AEF6B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:58:08 -0500 (EST)
Date: Tue, 5 Feb 2013 14:58:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slob: Check for NULL pointer before calling ctor()
In-Reply-To: <1360073811.27007.13.camel@gandalf.local.home>
Message-ID: <0000013caadd2e2f-3ca39b5e-cc18-4a38-9485-d505a89098af-000000@email.amazonses.com>
References: <1358442826.23211.18.camel@gandalf.local.home> <1360073811.27007.13.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, 5 Feb 2013, Steven Rostedt wrote:

> Ping?

Obviously correct.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
