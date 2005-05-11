Message-ID: <42825236.1030503@engr.sgi.com>
Date: Wed, 11 May 2005 13:43:02 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de>
In-Reply-To: <20050511125932.GW25612@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>>But, we do such things by consensus and I am willing to try to implement
>>whatever convention we all agree on.  I would like to have an agreement
>>from all parties before I proceed with an alternative implementation.
>>I will pursue the ld.so changes with the glibc-developers and see what
>>the reaction is.
> 
> 
> 
> I think Christoph's reaction mostly comes from trying to do this
> in file system specific code. Rather it should be some independent
> piece of code that just uses the EA interfaces offered by the FS
> to do this.
> 
> -Andi
> 

If we are going to use a "system" attribute, as near as I can tell, this
requires a change in the file system specific code.  If we use a "user"
attribute, then no fs change is required.  However, in the latter case
there is also no way to reserve a name that users can't overwrite or usurp.

However, I think that a "user" attribute might be workable.  For most
files that we would be marking this way (e. g. /lib and /usr/lib), a
non-root user can't change the user attributes anyway, since normal
protection rules apply.  For mapped files in other places, the chances
of a collision on the user.migration attribute are sufficiently small,
I would think, that we could live with that.  (A user would have to use
the same name and the same values that the kernel is looking for to
have an effect.)

The only remaining issue is the use of a "user" attribute to communicate
with the kernel.  That makes me uneasy as I don't know if this would
follow the normal conventions for extended attribute usage.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
