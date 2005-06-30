Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5UJ2UMp822064
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 15:02:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5UJ2UcC190246
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:02:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5UJ2U89032060
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:02:30 -0600
Subject: Re: [ckrm-tech] [PATCH 2/6] CKRM: Core framework support
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <1120157759.12143.64.camel@localhost>
References: <1119905417.14910.22.camel@linuxchandra>
	 <1120008141.723898.2904.nullmailer@yamt.dyndns.org>
	 <1120154907.14910.32.camel@linuxchandra>
	 <1120157759.12143.64.camel@localhost>
Content-Type: text/plain
Date: Thu, 30 Jun 2005 12:02:28 -0700
Message-Id: <1120158149.14910.48.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-30 at 11:55 -0700, Dave Hansen wrote:
> On Thu, 2005-06-30 at 11:08 -0700, Chandra Seetharaman wrote:
> > On Wed, 2005-06-29 at 10:22 +0900, YAMAMOTO Takashi wrote:
> > > > > > +	if (pud_none(*pud))
> > > > > > +		return 0;
> > > > > > +	BUG_ON(pud_bad(*pud));
> > > > > > +	pmd = pmd_offset(pud, address);
> > > > > > +	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;
> > > > > 
> > > > > why didn't you introduce class_migrate_pud?
> > > > 
> > > > Because there is no list to iterate through. 
> > > 
> > > i don't understand what you mean.
> > > why you don't iterate pud, while you iterate pgdir and pmd?
> > 
> > what i meant was that the pmd are an array and there is no array
> > w.r.t puds. correct me if i am wrong.
> 
> You are wrong :)
> 
> PUDs are the new level added to the pagetables for the architectures
> with larger address spaces.  They are equivalent in functionality to all
> other levels, and must be treated as such in any generic code.  
> 
> For 2 or 3-level pagetables, they do effectively collapse down to
> nothing, but you still have to be concerned with it in generic code.

Thanks Dave/Takashi, 

I will fix the code accordingly
> 
> -- Dave
> 
-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
