Date: Tue, 22 Feb 2005 19:03:57 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview II
Message-ID: <20050222180357.GP23433@wotan.suse.de>
References: <20050217235437.GA31591@wotan.suse.de> <4215A992.80400@sgi.com> <20050218130232.GB13953@wotan.suse.de> <42168FF0.30700@sgi.com> <20050220214922.GA14486@wotan.suse.de> <20050220143023.3d64252b.pj@sgi.com> <20050220223510.GB14486@wotan.suse.de> <42199EE8.9090101@sgi.com> <20050221121010.GC17667@wotan.suse.de> <421A166E.2030805@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421A166E.2030805@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, ak@muc.de, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 21, 2005 at 11:12:14AM -0600, Ray Bryant wrote:
> Andi Kleen wrote:
> 
> 
> >
> >I wouldn't bother fixing up VMA policies. 
> >
> >
> 
> How would these policies get changed so that they represent the
> reality of the new node location(s) then?  Doesn't this have to
> happen as part of migrate_pages()?

You might want to change it, but it's a pure policy issue. And
such kind of policy should be in user space. However I can see
it being ugly to grab the list of policies from user space
(it would need a /proc file). 

Perhaps you're right and it's better to do in the kernel.
It just won't be very pretty code to convert all the masks.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
