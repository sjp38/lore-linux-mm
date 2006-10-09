Subject: Re: [rfc] 2.6.19-rc1-git5: consolidation of file backed fault
	handlers
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1160427472.7752.15.camel@localhost.localdomain>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <1160427472.7752.15.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 07:00:38 +1000
Message-Id: <1160427638.7752.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-10-10 at 06:57 +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2006-10-09 at 18:12 +0200, Nick Piggin wrote:
> > OK, I've cleaned up and further improved this patchset, removed duplication
> > while retaining legacy nopage handling, restored page_mkwrite to the ->fault
> > path (due to lack of users upstream to attempt a conversion), converted the
> > rest of the filesystems to use ->fault, restored MAP_POPULATE and population
> > of remap_file_pages pages, replaced nopfn completely, and removed
> > NOPAGE_REFAULT because that can be done easily with ->fault.
> 
> What is the replacement ?

I see ... so we now use PTR_ERR to return errors and NULL for refault...
good for me but Andrew may want more...

Ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
