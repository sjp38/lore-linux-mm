Received: from CLNT37 [172.16.0.37] by omnesysindia.com [202.140.148.138]
	with SMTP (MDaemon.v2.83.R)
	for <linux-mm@kvack.org>; Wed, 04 Feb 2004 12:25:15 +0530
Message-ID: <018601c3eaeb$a1ba2150$250010ac@CLNT37>
From: "Arunkumar" <akumars@omnesysindia.com>
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com> <1075874074.14153.159.camel@nighthawk>  <35380000.1075874735@[10.10.2.4]> <1075875756.14153.251.camel@nighthawk> <38540000.1075876171@[10.10.2.4]>
Subject: Doubt about statm_pgd_range patch
Date: Wed, 4 Feb 2004 12:23:44 +0530
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I had a doubt as to why the vsize reported in /proc/nn/stat
and /proc/nn/statm differs. My search on the topic lead me 
to the details about the stam_pgd_range sucks patch 
(William Lee Irwin III) which is now included the latest 
2.6.xxx RC mm series.

I guess if i make similar changes to proc/array.c according 
to those patches, both stat and statm will report the vsize 
in the same manner - 

(vma->vm_end - vma->vm_start)

with statm reporting in pages and stat reporting in bytes

If this is the case can i report vsize of my process from 
/proc/self/stat value to be more correct than that in statm?
(iam running 2.4 kernel and stat already reports vsize in 
this manner in 2.4 kernels right ?)

Or does this patch need any other changes in kernel 
vm structures etc ?

Thanks
Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
