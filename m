Date: Tue, 6 May 2008 10:48:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: make vmstat cpu-unplug safe
In-Reply-To: <20080506154938.AC6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0805061047290.23336@schroedinger.engr.sgi.com>
References: <20080506154938.AC6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 May 2008, KOSAKI Motohiro wrote:
 
> btw: I think all_vm_event() author is Cristoph Lameter, right?

Welll I am the last one who reworked it from earlier incarnations.

> When access cpu_online_map, We should prevent that dynamically 
> change cpu_online_map by get_online_cpus().
> 
> Unfortunately, all_vm_events() doesn't it.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
