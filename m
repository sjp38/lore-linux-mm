Date: Mon, 1 May 2006 09:23:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [RFC] Hugetlb fallback to normal pages
In-Reply-To: <1146498407.32079.15.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605010921210.15082@schroedinger.engr.sgi.com>
References: <4sur0l$s7b0u@fmsmga001.fm.intel.com> <1146498407.32079.15.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2006, Dave Hansen wrote:

> What are the restrictions on ia64?

IA64 has a special virtual address range for huge page tables. We would 
first have to introduce various page sizes in the virtual address range 
for huge pages (I think Ken is working on something like that) and then 
the fallback could only be to a "huge" page of order 0. But then the page
would still not behave like a normal page.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
