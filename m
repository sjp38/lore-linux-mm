From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of physical pages backing it
Date: Mon, 12 Jun 2006 14:54:34 +0200
References: <1149903235.31417.84.camel@galaxy.corp.google.com> <200606121317.44139.ak@suse.de> <Pine.LNX.4.61.0606121449140.1125@yvahk01.tjqt.qr>
In-Reply-To: <Pine.LNX.4.61.0606121449140.1125@yvahk01.tjqt.qr>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606121454.34072.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: Arjan van de Ven <arjan@infradead.org>, rohitseth@google.com, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 12 June 2006 14:49, Jan Engelhardt wrote:
> >
> >I agree it's a bad idea. smaps is only a debugging kludge anyways
> >and it's not a good idea to we bloat core data structures for it.
> >
> Is there a way to disable it (smaps), then?

Just don't use it?  

Not set CONFIG_NUMA?  

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
