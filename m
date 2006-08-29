Date: Tue, 29 Aug 2006 16:57:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: libnuma interleaving oddness
In-Reply-To: <20060829231545.GY5195@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com>
References: <20060829231545.GY5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 Aug 2006, Nishanth Aravamudan wrote:

> I don't know if this is a libnuma bug (I extracted out the code from
> libnuma, it looked sane; and even reimplemented it in libhugetlbfs for
> testing purposes, but got the same results) or a NUMA kernel bug (mbind
> is some hairy code...) or a ppc64 bug or maybe not a bug at all.
> Regardless, I'm getting somewhat inconsistent behavior. I can provide
> more debugging output, or whatever is requested, but I wasn't sure what
> to include. I'm hoping someone has heard of or seen something similar?

Are you setting the tasks allocation policy before the allocation or do 
you set a vma based policy? The vma based policies will only work for 
anonymous pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
