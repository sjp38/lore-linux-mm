In-reply-to: <1177406817.26937.65.camel@twins> (message from Peter Zijlstra on
	Tue, 24 Apr 2007 11:26:57 +0200)
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
References: <20070420155154.898600123@chello.nl>
	 <20070420155503.608300342@chello.nl>
	 <17965.29252.950216.971096@notabene.brown>
	 <1177398589.26937.40.camel@twins>
	 <E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
	 <1177403494.26937.59.camel@twins>
	 <E1HgH69-0000Fl-00@dorka.pomaz.szeredi.hu> <1177406817.26937.65.camel@twins>
Message-Id: <E1HgHcG-0000J5-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Apr 2007 11:47:20 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, neilb@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

> Ahh, now I see; I had totally blocked out these few lines:
> 
> 			pages_written += write_chunk - wbc.nr_to_write;
> 			if (pages_written >= write_chunk)
> 				break;		/* We've done our duty */
> 
> yeah, those look dubious indeed... And reading back Neil's comments, I
> think he agrees.
> 
> Shall we just kill those?

I think we should.

Athough I'm a little afraid, that Akpm will tell me again, that I'm a
stupid git, and that those lines are in fact vitally important ;)

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
