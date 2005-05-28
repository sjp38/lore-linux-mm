Message-ID: <429893FA.3090703@austin.rr.com>
Date: Sat, 28 May 2005 10:53:30 -0500
From: Ray Bryant <raybry@austin.rr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 -- add-sys_migrate_pages-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043821.10876.47127.71762@jackhammer.engr.sgi.com> <20050511082457.GA24134@infradead.org> <428B9269.2080907@engr.sgi.com> <20050528091455.GB19330@infradead.org>
In-Reply-To: <20050528091455.GB19330@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ray Bryant <raybry@engr.sgi.com>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:

>
>I looked over the code again and most of the migration code isn't added
>in the patchkit but expected to exist already, thus I'm not sure what's
>going on at all.
>  
>
Yes, as discussed in the overview, the manual page migration code 
depends on the page migration
code from the memory hotplug patch.  The plan is to merge the manual 
page migration code into
the page migration subpatch of the memory hotplug code and then I will 
work on merging that
page migration code itself.

>address_space_operations are the wrong abstraction here, you're operating
>on VMAs, thus any vectoring should happen at the vm_operations_struct
>level.
>
>  
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
