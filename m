Date: Tue, 24 Jun 2008 15:46:54 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
Message-ID: <20080624114654.GA27123@2ka.mipt.ru>
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 24, 2008 at 01:36:35PM +0200, Miklos Szeredi (miklos@szeredi.hu) wrote:
> > basically like PageWriteback(), but for read-in.
> 
> OK it could be done, possibly at great pain.  But why is it important?

Maybe not that great if mark all readahead pages as, well, readahead,
and do the same for readpage (essnetially it is the same).

> What's the use case where it matters that splice-in should not block
> on the read?

To be able to transfer what was already read?

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
