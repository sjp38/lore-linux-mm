Subject: Re: FW: [PATCH 0/3] Demand faulting for huge pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB5086AF0DF@scsmsx401.amr.corp.intel.com>
References: <B05667366EE6204181EABE9C1B1C0EB5086AF0DF@scsmsx401.amr.corp.intel.com>
Content-Type: text/plain
Date: Fri, 07 Oct 2005 14:28:37 -0700
Message-Id: <1128720518.32679.15.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com, agl@us.ibm.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-07 at 10:47 -0700, Adam Litke wrote:
>  
> 
> If I were to spend time coding up a patch to remove truncation support
> for hugetlbfs, would it be something other people would want to see
> merged as well?
> 

In its current form, there is very little use of huegtlb truncate
functionality.  Currently it only allows reducing the size of hugetlb
backing file.   

IMO it will be useful to keep and enhance this capability so that apps
can dynamically reduce or increase the size of backing files (for
example based on availability of memory at any time).

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
