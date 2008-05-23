Date: Fri, 23 May 2008 07:29:17 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 11/18] mm: export prep_compound_page to mm
Message-ID: <20080523052917.GJ13071@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.814185000@nick.local0.net> <480F600B.9000802@cray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480F600B.9000802@cray.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Hastings <abh@cray.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:12:59AM -0500, Andrew Hastings wrote:
> npiggin@suse.de wrote:
> >hugetlb will need to get compound pages from bootmem to handle
> >the case of them being larger than MAX_ORDER. Export
> 
> s/larger/greater than or equal to/

Good catch, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
