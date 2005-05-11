Message-ID: <4282815F.1000100@engr.sgi.com>
Date: Wed, 11 May 2005 17:04:15 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> <20050511193207.GE11200@wotan.suse.de> <20050511200033.GA2646@infradead.org>
In-Reply-To: <20050511200033.GA2646@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Wed, May 11, 2005 at 09:32:07PM +0200, Andi Kleen wrote:
> 
>>hch: if you still are against this please reread the original thread
>>with me and Ray and see why we decided that ld.so changes are not
>>a good idea.
> 
> 
> please send a pointer to the discussion.
> 

The thread starts here:

http://marc.theaimsgroup.com/?l=linux-mm&m=110817907931126&w=2

> Not that I think it matters a lot.  What Ray implemented is a very
> special cased hack for migration policies that only applies to shared
> libraries.  Doing it generically is about the same amount of code and
> a lot cleaner.
> 
> Note that I'm not against storing information in the file so that
> shared libraries get the proper treatment, but the proper place for
> that is an additional ELF header or magic section, similar to the
> noexec stack changes.
> 

Can you help me get the glibc developers to buy into the necessary
changes to ld.so?  (Isn't that where such changes would end up being
made?)

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
