Date: Wed, 20 Aug 2008 23:46:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of
 CPUs
Message-Id: <20080820234615.258a9c04.akpm@linux-foundation.org>
In-Reply-To: <20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Aug 2008 20:08:13 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +	num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));

sparc64 allmodconfig:

mm/quicklist.c: In function `max_pages':
mm/quicklist.c:44: error: invalid lvalue in unary `&'

we seem to have a made a spectacular mess of cpumasks lately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
