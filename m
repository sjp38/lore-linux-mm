Subject: Re: returning non-ram via ->nopage, was Re: [patch] mspec driver for 2.6.12-rc2-mm3
References: <16987.39773.267117.925489@jaguar.mkp.net>
	<20050412032747.51c0c514.akpm@osdl.org>
	<yq07jj8123j.fsf@jaguar.mkp.net>
	<20050413204335.GA17012@infradead.org>
	<yq08y3bys4e.fsf@jaguar.mkp.net>
	<20050424101615.GA22393@infradead.org>
	<yq03btftb9u.fsf@jaguar.mkp.net>
	<20050425144749.GA10093@infradead.org>
	<yq0ll75rxsl.fsf@jaguar.mkp.net> <426FB56B.5000006@pobox.com>
	<20050427155526.GA25921@infradead.org>
From: Jes Sorensen <jes@wildopensource.com>
Date: 27 Apr 2005 14:03:50 -0400
In-Reply-To: <20050427155526.GA25921@infradead.org>
Message-ID: <yq0hdhsrta1.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Christoph" == Christoph Hellwig <hch@infradead.org> writes:

Christoph> On Wed, Apr 27, 2005 at 11:53:15AM -0400, Jeff Garzik
Christoph> wrote:
>> I don't see anything wrong with a ->nopage approach.
>> 
>> At Linus's suggestion, I used ->nopage in the implementation of
>> sound/oss/via82cxxx_audio.c.

Christoph> The difference is that you return kernel memory (actually
Christoph> pci_alloc_consistant memory that has it's own set of
Christoph> problems), while this is memory not in mem_map, so he
Christoph> allocates some regularly kernel memory too to have a struct
Christoph> page and just leaks it

Are you suggesting then that we change do_no_page to handle this as a
special return value then?

Jes
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
