From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: slow hugetlb from 2.6.15
Date: Tue, 27 Jun 2006 15:00:09 -0700
Message-ID: <000101c69a35$0fee2f90$e234030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1151445073.24103.37.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Dave Hansen' <haveblue@us.ibm.com>
Cc: 'Badari Pulavarty' <pbadari@gmail.com>, stanojr@blackhole.websupport.sk, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote on Tuesday, June 27, 2006 2:51 PM
> On Tue, 2006-06-27 at 12:23 -0700, Chen, Kenneth W wrote:
> >   Though it is a mystery to
> > see that faulting on hugetlb page is significantly longer than
> > faulting a normal page.
> 
> There's an awful lot more data to zero when allocating a page which is
> 1000 times bigger.  It would be really interesting to see kernel
> profiles, but my money is on clear_huge_page().


I was under the impression that the test code will touch equal amount of
memory for both hugetlb page and normal pages.  Yes, faulting one hugetlb
page will require zeroing 1024 times more memory than a normal page, but
yet it will be 1024 times less of number of page fault.  I was referring
to time required to fault 1 hugetlb page at 4MB versus 1024 normal page
fault at 4KB. I wasn't expecting the former to be longer than the latter.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
