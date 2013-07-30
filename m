Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 3C5626B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 12:48:10 -0400 (EDT)
Message-ID: <51F7ED29.7080606@intel.com>
Date: Tue, 30 Jul 2013 09:43:21 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: page_alloc: Add unlikely for MAX_ORDER check
References: <1375022906-1164-1-git-send-email-waydi1@gmail.com> <51F6F087.9060109@linux.intel.com> <51F70A9F.2000309@linux.vnet.ibm.com> <51F714D4.9070005@linux.vnet.ibm.com>
In-Reply-To: <51F714D4.9070005@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, SeungHun Lee <waydi1@gmail.com>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, xinxing2zhou@gmail.com

Cody, it's a good point that we shouldn't be looking at something as
simplistic as the file sizes.  I also used whole vmlinux's and turned
off debuginfo:

   text	   data	    bss	    dec	    hex	filename
10064322	1980968	3051520	15096810	 e65bea	vmlinux.nothing
10064451	1980968	3051520	15096939	 e65c6b	vmlinux.unlikely

So it still cost ~130 bytes of text.  Also, perusing the vmlinux
objdump, adding the unlikely() does look to take
__alloc_pages_direct_compact and move it _closer_ to the page allocation
code.

What does this all mean?  Hell if I know.  It's up to the patch
submitter to explain the implications of the patch. ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
