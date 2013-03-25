Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 677AE6B009F
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 14:00:19 -0400 (EDT)
Date: Mon, 25 Mar 2013 18:00:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: BUG at kmem_cache_alloc
In-Reply-To: <364499626.5604667.1364189870552.JavaMail.root@redhat.com>
Message-ID: <0000013da2b53120-1c207286-3e36-483e-9fd9-90fc529d48aa-000000@email.amazonses.com>
References: <364499626.5604667.1364189870552.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>


Please enable CONFIG_SLUB_DEBUG_ON or run the kernel with slub_debug on
the command line to get detailed diagnostics as to what causes this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
