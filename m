Subject: Re: [PATCH 00/12] per device dirty throttling -v3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070405174209.498059336@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
Content-Type: text/plain
Date: Thu, 05 Apr 2007 19:47:33 +0200
Message-Id: <1175795253.6483.110.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

Don't worry, it's me!

Seems I forgot to edit the From field :-(

On Thu, 2007-04-05 at 19:42 +0200, root@programming.kicks-ass.net wrote:
> Against 2.6.21-rc5-mm4 without:
>   per-backing_dev-dirty-and-writeback-page-accounting.patch
> 
> This series implements BDI independent dirty limits and congestion control.
> 
> This should solve several problems we currently have in this area:
> 
>  - mutual interference starvation (for any number of BDIs), and
>  - deadlocks with stacked BDIs (loop and FUSE).
> 
> All the fancy new congestion code has been compile and boot tested, but
> not much more. I'm posting to get feedback on the ideas.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
