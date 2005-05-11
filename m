Message-ID: <4281F650.2020807@engr.sgi.com>
Date: Wed, 11 May 2005 07:10:56 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org>
In-Reply-To: <20050511071538.GA23090@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Tue, May 10, 2005 at 09:38:02PM -0700, Ray Bryant wrote:
> 
>>This patch is from Nathan Scott of SGI and adds the extended
>>attribute system.migration for xfs.  At the moment, there is
>>no protection checking being done here (according to Nathan),
>>so this would have to be added if we finally agree to go this
>>way. 
> 
> 
> As Nathan and I told you this is not acceptable at all.  Imigration policies
> don't belong into filesystem metadata.
> 
> 
> 

Is the issue here the use of extended attributes, period, or the use of the
system name space?  If it is the latter, we could readily convert to using
a name in the user name space instead and that would eliminate the need
for this xfs patch, which is certainly desirable and would eliminate the
need for other fs patches of a similar sort.  Of course, there is no way
to guarentee that this name is not already used (or will be used in the
future) in the user name space for a different purpose.  But we can
probably live with that.

I would observe that after lengthy discussion on this topic in February
with Andi, use of extended attributes was agreed upon as the preferred
solution.  Your alternative (As I recall: modifying the dynamic loader
to mark mapped files in memory as shared libraries, and requiring a new
mmap() flag to mark files as non-migratable) strikes me as more
complicated and even harder to get accepted by the community, since it
touches not only the kernel, but glibc as well.

But, we do such things by consensus and I am willing to try to implement
whatever convention we all agree on.  I would like to have an agreement
from all parties before I proceed with an alternative implementation.
I will pursue the ld.so changes with the glibc-developers and see what
the reaction is.

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
