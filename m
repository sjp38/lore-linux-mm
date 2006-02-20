Subject: Re: VM_PFNMAP and do_no_pfn handler
References: <yq0y806qfgd.fsf@jaguar.mkp.net>
	<Pine.LNX.4.61.0602201526260.12160@goblin.wat.veritas.com>
From: Jes Sorensen <jes@sgi.com>
Date: 20 Feb 2006 10:55:26 -0500
In-Reply-To: <Pine.LNX.4.61.0602201526260.12160@goblin.wat.veritas.com>
Message-ID: <yq0psliqb2p.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Carsten Otte <cotte@de.ibm.com>, roe@sgi.com, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

>>>>> "Hugh" == Hugh Dickins <hugh@veritas.com> writes:

Hugh> On Mon, 20 Feb 2006, Jes Sorensen wrote:
>> Any suggestions? (or rather, what obvious thing did I miss? ;-)

Hugh> I believe you'll be safe for as long as your driver prohibits
Hugh> COW mappings.  You're not the only one to have VM_PFNMAP areas
Hugh> which don't follow Linus' vm_pgoff rule: which is why he added
Hugh> the !is_cow_mapping letout late in 2.6.15-rc.  We cannot change
Hugh> that lightly.

Hugh> I think you're worrying too much, unless you anticipate wanting
Hugh> to extend to COW mappings later.  That would indeed need
Hugh> vm_normal_page to be changed (and I know what change to make,
Hugh> but Linus hated it!).

Hi Hugh,

Thanks for the explanation. It just seemed to me that is_cow_mapping()
seemed a bit of a strange name for a
'this_mapping_really_has_no_struct_page_behind_it_honest()' function.
Is there some reason why we try to look up the struct page for
anything mapped VM_PFNMAP?

I can live with the current situation, but maybe it would be worth
adding some extra explanation to vm_normal_page() then?

I hope to post the changes I have in mind for do_no_pfn() and the
driver within a couple of days for those who are interested.

Cheers,
Jes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
