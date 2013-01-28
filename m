Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id D48C96B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:08:56 -0500 (EST)
Date: Mon, 28 Jan 2013 15:08:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/11] ksm: allow trees per NUMA node
Message-Id: <20130128150854.6813b1ca.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1301251753380.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	<alpine.LNX.2.00.1301251753380.29196@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Jan 2013 17:54:53 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> +/* Zeroed when merging across nodes is not allowed */
> +static unsigned int ksm_merge_across_nodes = 1;

I spose this should be __read_mostly.  If __read_mostly is not really a
synonym for __make_write_often_storage_slower.  I continue to harbor
fear, uncertainty and doubt about this...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
