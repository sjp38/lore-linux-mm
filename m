Date: Mon, 5 May 2008 11:58:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 1/2] Add shared and reserve control to hugetlb_file_setup
Message-ID: <20080505105826.GA11027@csn.ul.ie>
References: <1209693089.8483.22.camel@grover.beaverton.ibm.com> <1209744977.7763.29.camel@nimitz.home.sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1209744977.7763.29.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: ebmunson@us.ibm.com, linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On (02/05/08 09:16), Dave Hansen didst pronounce:
> On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote:
> > In order to back stacks with huge pages, we will want to make hugetlbfs
> > files to back them; these will be used to back private mappings.
> > Currently hugetlb_file_setup creates files to back shared memory segments.
> > Modify this to create both private and shared files,
> 
> Hugetlbfs can currently have private mappings, right?  Why not just use
> the existing ones instead of creating a new variety with
> hugetlb_file_setup()?
> 

hugetlb_file_setup() uses an internal mount to create files just for
SHM. However, it does the work necessary for MAP_SHARED mappings,
particularly reserve pages. The account is currently all fouled up to
deal with a private mapping that has reserves. Teaching
hugetlb_file_setup() to deal with private and shared mappings does
appear the most straight-forward route.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
