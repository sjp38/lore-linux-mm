Subject: Re: [RFC] mmaped copy too slow?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080115180130.119A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115115318.1191.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1200387478.15103.21.camel@twins>
	 <20080115180130.119A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 15 Jan 2008 10:08:27 +0100
Message-Id: <1200388107.15103.23.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-15 at 18:03 +0900, KOSAKI Motohiro wrote:
> Hi Peter,
> 
> > > > While being able to deal with used-once mappings in page reclaim
> > > > could be a good idea, this would require us to be able to determine
> > > > the difference between a page that was accessed once since it was
> > > > faulted in and a page that got accessed several times.
> > > 
> > > it makes sense that read ahead hit assume used-once mapping, may be.
> > > I will try it.
> > 
> > I once had a patch that made read-ahead give feedback into page reclaim,
> > but people didn't like it.
> 
> Could you please tell me your mail subject or URL?
> I hope know why people didn't like.

I think this is the last thread on the subject:

  http://lkml.org/lkml/2007/7/21/219



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
