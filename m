Message-Id: <200603310120.k2V1KDg27257@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] don't allow free hugetlb count fall below reserved count
Date: Thu, 30 Mar 2006 17:20:58 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20060331004156.GK19421@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Thursday, March 30, 2006 4:42 PM
> Ken - did you keep working on your alternative strict reservation
> patches?  Last I recall they seemed to be converging on mine in all
> the points I thought really mattered, except that I hadn't updated
> mine to remove some of the problems you pointed out in it while
> developing your patches (e.g. unnecessarily taking a lock on reserve).
> 
> I'm actually on a very long leave at the moment, so I'm not really
> doing anything active.  Those problems should be fixed at some point,
> though, either with patches to my approach, or by replacing it with
> yours.


Since andrew already merged your reservation patch for 2.6.17, I will
shelf mine for now ...

I will work on the base kernel and add stuff to the current code.


- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
