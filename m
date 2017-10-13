From: Christopher Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Fri, 13 Oct 2017 10:56:13 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com> <20171012014611.18725-1-mike.kravetz@oracle.com> <20171012014611.18725-4-mike.kravetz@oracle.com> <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz> <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz> <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake> <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz> <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake> <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171013154747.2jv7rtfqyyagiodn-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Mike Kravetz <mike.kravetz-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>, "Aneesh Kumar K . V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Joonsoo Kim <iamjoonsoo.kim-Hm3cg6mZ9cc@public.gmane.org>, Guy Shattah <sguy-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Anshuman Khandual <khandual-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Laura Abbott <labbott-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
List-Id: linux-mm.kvack.org

On Fri, 13 Oct 2017, Michal Hocko wrote:

> > There is a generic posix interface that could we used for a variety of
> > specific hardware dependent use cases.
>
> Yes you wrote that already and my counter argument was that this generic
> posix interface shouldn't bypass virtual memory abstraction.

It does do that? In what way?

> > There are numerous RDMA devices that would all need the mmap
> > implementation. And this covers only the needs of one subsystem. There are
> > other use cases.
>
> That doesn't prevent providing a library function which could be reused
> by all those drivers. Nothing really too much different from
> remap_pfn_range.

And then in all the other use cases as well. It would be much easier if
mmap could give you the memory you need instead of havig numerous drivers
improvise on their own. This is in particular also useful
for numerous embedded use cases where you need contiguous memory.
