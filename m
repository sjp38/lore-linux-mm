Date: Fri, 14 Sep 2007 10:43:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] hugetlb: search harder for memory in alloc_fresh_huge_page()
In-Reply-To: <20070914172638.GT24941@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0709141041390.15683@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com> <20070914172638.GT24941@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007, Nishanth Aravamudan wrote:

> Christoph, Lee, ping? I haven't heard any response on these patches this
> time around. Would it be acceptable to ask Andrew to pick them up for
> the next -mm?

I am sorry but there is some churn already going on with other core memory 
management patches. Could we hold this off until the dust settles on those 
and then rebase?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
