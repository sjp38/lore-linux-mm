Subject: Re: [PATCH 1/6] mm: scalable bdi statistics counters.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HZ1fn-0005oT-00@dorka.pomaz.szeredi.hu>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.227434440@taijtu.programming.kicks-ass.net>
	 <E1HZ1fn-0005oT-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 11:25:38 +0200
Message-Id: <1175678738.6483.30.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 11:20 +0200, Miklos Szeredi wrote:
> > Provide scalable per backing_dev_info statistics counters modeled on the ZVC
> > code.
> 
> Why do we need global_bdi_stat()?  It should give approximately the
> same numbers as global_page_state(), no?

For those counters that are shared, yes. However I find it not obvious
that all BDI counter will always be mirrored in the page stats, and I
actually use it in 6/6, which introduces counters that are not mirrored
in the page stats.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
