From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Fri, 13 Oct 2017 10:20:06 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com> <20171012014611.18725-1-mike.kravetz@oracle.com> <20171012014611.18725-4-mike.kravetz@oracle.com> <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz> <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>
List-Id: linux-mm.kvack.org

On Fri, 13 Oct 2017, Michal Hocko wrote:

> I would, quite contrary, suggest a device specific mmap implementation
> which would guarantee both the best memory wrt. physical contiguous
> aspect as well as the placement - what if the device have a restriction
> on that as well?

Contemporary high end devices can handle all of memory. If someone does
not have the requirements to get all that hardware can give you in terms
of speed then they also wont need contiguous memory.

> > Yes, it remains contiguous.  It is locked in memory.
>
> Hmm, so hugetlb on steroids...

Its actually better because there is no requirements of allocation in
exacytly 2M chunks. The remainder can be used for regular 4k page
allocations.

> > > Who is going to use such an interface? And probably many other
> > > questions...
> >
> > Thanks for asking.  I am just throwing out the idea of providing an interface
> > for doing contiguous memory allocations from user space.  There are at least
> > two (and possibly more) devices that could benefit from such an interface.
>
> I am not really convinced this is a good interface. You are basically
> trying to bypass virtual memory abstraction and that is quite
> contradicting the mmap API to me.

This is a standardized posix interface as described in our presentation at
the plumbers conference. See the presentation on contiguous allocations.

The contiguous allocations are particularly useful for the RDMA API which
allows registering user space memory with devices.
