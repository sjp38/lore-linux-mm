From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Fri, 13 Oct 2017 10:14:16 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710131013210.3949@nuc-kabylake>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com> <20171012014611.18725-1-mike.kravetz@oracle.com> <20171012014611.18725-4-mike.kravetz@oracle.com> <5ea60591-c9b5-6520-6292-7a4d6fd04b5f@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5ea60591-c9b5-6520-6292-7a4d6fd04b5f@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>
List-Id: linux-mm.kvack.org

On Thu, 12 Oct 2017, Anshuman Khandual wrote:

> > +static long __alloc_vma_contig_range(struct vm_area_struct *vma)
> > +{
> > +	gfp_t gfp = GFP_HIGHUSER | __GFP_ZERO;
>
> Would it be GFP_HIGHUSER_MOVABLE instead ? Why __GFP_ZERO ? If its
> coming from Buddy, every thing should have already been zeroed out
> in there. Am I missing something ?

Contiguous pages cannot and should not be moved. They will no longer be
contiguous then. Also the page migration code cannot handle this case.
