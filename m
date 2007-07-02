Date: Tue, 3 Jul 2007 01:09:15 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: vm/fs meetup in september?
Message-ID: <20070702230914.GB5630@lazybastard.org>
References: <20070624042345.GB20033@wotan.suse.de> <20070625063545.GA1964@infradead.org> <46807B5D.6090604@yahoo.com.au> <20070630093129.GC22354@infradead.org> <46864DF8.6090807@mbligh.org> <20070702061944.GA31557@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070702061944.GA31557@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Christoph Hellwig <hch@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 July 2007 08:19:44 +0200, Nick Piggin wrote:
> 
> Regarding numbers, there are about a dozen so far which is good
> but not as many filesystem maintainers as I had hoped (do they
> tend not to get invited to KS?). We may get a few more people yet
> so I think if we try to get a room to fit 20-25 people it would
> be ideal: I don't want to turn anyone away ;)

I'm interested.

My particular pet subject would be sync behaviour.  LogFS benefits from
writing data in a particular order - data first, then indirect blocks,
doubly indirect, triply, etc.  Reason is that indirect blocks get
dirtied when data is written.

The current solution is to write indirect blocks immediatly, causing
quite bad performance.

JA?rn

-- 
Measure. Don't tune for speed until you've measured, and even then
don't unless one part of the code overwhelms the rest.
-- Rob Pike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
