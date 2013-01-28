Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0722A6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:11:20 -0500 (EST)
Date: Mon, 28 Jan 2013 15:11:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/11] ksm: trivial tidyups
Message-Id: <20130128151119.b74d0150.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1301251757020.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	<alpine.LNX.2.00.1301251757020.29196@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Jan 2013 17:58:11 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> +#ifdef CONFIG_NUMA
> +#define NUMA(x)		(x)
> +#define DO_NUMA(x)	(x)

Did we consider

	#define DO_NUMA do { (x) } while (0)

?

That could avoid some nasty config-dependent compilation issues.

> +#else
> +#define NUMA(x)		(0)
> +#define DO_NUMA(x)	do { } while (0)
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
