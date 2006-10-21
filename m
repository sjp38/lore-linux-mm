Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id k9L4E2JS210034
	for <linux-mm@kvack.org>; Sat, 21 Oct 2006 14:14:06 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9L47TFw008678
	for <linux-mm@kvack.org>; Sat, 21 Oct 2006 14:07:34 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9L443El026740
	for <linux-mm@kvack.org>; Sat, 21 Oct 2006 14:04:03 +1000
In-Reply-To: <Pine.LNX.4.64.0610202253190.963@blonde.wat.veritas.com>
Subject: Re: [patch 1/2] shared page table for hugetlb page - v4
Message-ID: <OF0E72870E.E9DCF51F-ON4A25720E.001579A7-4A25720E.0016500F@au1.ibm.com>
From: Hugh Blemings <hab@au1.ibm.com>
Date: Sat, 21 Oct 2006 14:03:42 +1000
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




Hiya,

> You can add my
> Acked-by: Hugh Dickins <hugh@veritas.com>
> to both patches, but it's no longer worth much: I notice Andrew has
> grown so disillusioned by my sluggardly responses that he's rightly
> decided to CC Hugh Blemings instead ;)  Over to you, Hugh!

Patches look fine, at a cursory glance they seem to mainly be implementing
functionality on legacy architectures anyway :P

In case it will assist identification in the future, my learned colleague
is the dashing fellow on the left.  Perhaps we need to xfce support in
git/quilt ?

http://pics.blemings.org/gallery/deusca-200606/20060722_233006

Happy hacking :)

Hugh(B)



Hugh Blemings
Open Source Hacker
OzLabs, IBM Linux Technology Centre
phone: +61 2 6212 1177 (T/L 70 21177)   mobile: +61 411 647 662  fax: +61 2
6212 1187
Intranet: http://ozlabs.au.ibm.com
Internet: http://oss.software.ibm.com/developerworks/opensource/linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
