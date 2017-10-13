From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Fri, 13 Oct 2017 10:42:37 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com> <20171012014611.18725-1-mike.kravetz@oracle.com> <20171012014611.18725-4-mike.kravetz@oracle.com> <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz> <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz> <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake> <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>
List-Id: linux-mm.kvack.org

On Fri, 13 Oct 2017, Michal Hocko wrote:

> On Fri 13-10-17 10:20:06, Cristopher Lameter wrote:
> > On Fri, 13 Oct 2017, Michal Hocko wrote:
> [...]
> > > I am not really convinced this is a good interface. You are basically
> > > trying to bypass virtual memory abstraction and that is quite
> > > contradicting the mmap API to me.
> >
> > This is a standardized posix interface as described in our presentation at
> > the plumbers conference. See the presentation on contiguous allocations.
>
> Are you trying to desing a generic interface with a very specific and HW
> dependent usecase in mind?

There is a generic posix interface that could we used for a variety of
specific hardware dependent use cases.

> > The contiguous allocations are particularly useful for the RDMA API which
> > allows registering user space memory with devices.
>
> then make those devices expose an implementation of an mmap which does
> that. You would get both a proper access control (via fd), accounting
> and others.

There are numerous RDMA devices that would all need the mmap
implementation. And this covers only the needs of one subsystem. There are
other use cases.
