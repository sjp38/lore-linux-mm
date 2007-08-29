From: Oliver Neukum <oliver@neukum.org>
Subject: Re: speeding up swapoff
Date: Wed, 29 Aug 2007 18:18:42 +0200
References: <1188394172.22156.67.camel@localhost> <200708291636.48323.oliver@neukum.org> <Pine.LNX.4.64.0708291701140.617@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0708291701140.617@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200708291818.44089.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Daniel Drake <ddrake@brontes3d.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Am Mittwoch 29 August 2007 schrieb Hugh Dickins:
> On Wed, 29 Aug 2007, Oliver Neukum wrote:
> > Am Mittwoch 29 August 2007 schrieb Arjan van de Ven:
> > > Another question, if this is during system shutdown, maybe that's a
> > > valid case for flushing most of the pagecache first (from userspace)
> > > since most of what's there won't be used again anyway. If that's enough
> > > to make this go faster...
> > 
> > Is there a good reason to swapoff during shutdown?
> 
> Three reasons, I think, only one of them compelling:
> 
> 1. Tidiness.
> 2. So swapoff gets testing and I get to hear of any bugs in it.
> 3. If a regular swapfile is used instead of a disk partition, you
>    need to swapoff before its filesystem can be unmounted cleanly.

Yes. I hadn't thought of that. I am using a dedicated disk.

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
