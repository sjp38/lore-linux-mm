From: Andi Kleen <ak@suse.de>
Subject: Re: libnuma interleaving oddness
Date: Wed, 30 Aug 2006 09:32:23 +0200
References: <20060829231545.GY5195@us.ibm.com> <200608300919.13125.ak@suse.de> <20060830072948.GE5195@us.ibm.com>
In-Reply-To: <20060830072948.GE5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608300932.23746.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wednesday 30 August 2006 09:29, Nishanth Aravamudan wrote:

> 
> > Hmm, maybe mlock() policy() is broken.
> 
> I took out the mlock() call, and I get the same results, FWIW.

Then it's probably some new problem in hugetlbfs. Does it work with shmfs?

The regression test for hugetlbfs is numactl is unfortunately still disabled.
I need to enable it at some point for hugetlbfs now that it reached mainline.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
