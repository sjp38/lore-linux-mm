From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC] mmap(MAP_CONTIG)
Date: Wed, 4 Oct 2017 11:05:33 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710041104310.21484@nuc-kabylake>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com> <97c81533-5206-b130-1aeb-c5b9bfd93287@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97c81533-5206-b130-1aeb-c5b9bfd93287@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>
List-Id: linux-mm.kvack.org

On Wed, 4 Oct 2017, Anshuman Khandual wrote:

> > - Using 'pre-allocated' pages in the fault paths may be intrusive.
>
> But we have already faulted in all of them for the mapping and they
> are also locked. Hence there should not be any page faults any more
> for the VMA. Am I missing something here ?

The PTEs may be torn down and have to reestablished through a page faults.
Page faults would not allocate memory.

> I am still wondering why wait till fault time not pre fault all of them
> and populate the page tables.

They are populated but some processes (swap and migration) may tear them
down.
