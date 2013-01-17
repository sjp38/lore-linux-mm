Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 65F8B6B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 12:54:37 -0500 (EST)
Message-ID: <1358445275.23211.22.camel@gandalf.local.home>
Subject: [PATCH] slob: Check for NULL pointer before calling ctor()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 17 Jan 2013 12:54:35 -0500
In-Reply-To: <1358442826.23211.18.camel@gandalf.local.home>
References: <1358442826.23211.18.camel@gandalf.local.home>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

I'm not doing so well. I forgot to add [PATCH] to the subject.

Having all these scripts to push out patches in my normal work flow, has
made me incompetent in sending out patches manually. :-(

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
