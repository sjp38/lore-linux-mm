Date: Fri, 2 Jun 2006 14:08:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] hugetlb: powerpc: Actively close unused htlb regions on
 vma close
In-Reply-To: <1149281841.9693.39.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0606021407580.6179@schroedinger.engr.sgi.com>
References: <1149257287.9693.6.camel@localhost.localdomain>
 <Pine.LNX.4.64.0606021301300.5492@schroedinger.engr.sgi.com>
 <1149281841.9693.39.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jun 2006, Adam Litke wrote:

> The real reason I want to "close" hugetlb regions (even on 64bit
> platforms) is so a process can replace a previous hugetlb mapping with
> normal pages when huge pages become scarce.  An example would be the
> hugetlb morecore (malloc) feature in libhugetlbfs :)

Well that approach wont work on IA64 it seems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
