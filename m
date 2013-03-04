Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E95836B0007
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 00:50:58 -0500 (EST)
Date: Mon, 4 Mar 2013 16:13:40 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V1 07/24] powerpc: Add size argument to pgtable_cache_add
Message-ID: <20130304051340.GC27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361865914-13911-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361865914-13911-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Feb 26, 2013 at 01:34:57PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We will use this later with THP changes to request for pmd table of double the size.
> THP code does PTE page allocation along with large page request and deposit them
> for later use. This is to ensure that we won't have any failures when we split
> huge pages to regular pages.
> 
> On powerpc we want to use the deposited PTE page for storing hash pte slot and
> secondary bit information for the HPTEs. Hence we save them in the second half
> of the pmd table.

Looks OK, but you should explain why you made the wholesale change of
"shift" to "index".  Is there some important semantic difference, or
do you just prefer the "index" name for some reason?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
