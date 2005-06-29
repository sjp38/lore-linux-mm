Subject: Re: [ckrm-tech] [PATCH 2/6] CKRM: Core framework support
In-Reply-To: Your message of "Mon, 27 Jun 2005 13:50:17 -0700"
	<1119905417.14910.22.camel@linuxchandra>
References: <1119905417.14910.22.camel@linuxchandra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Date: Wed, 29 Jun 2005 10:22:21 +0900
Message-Id: <1120008141.723898.2904.nullmailer@yamt.dyndns.org>
From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > +	if (pud_none(*pud))
> > > +		return 0;
> > > +	BUG_ON(pud_bad(*pud));
> > > +	pmd = pmd_offset(pud, address);
> > > +	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;
> > 
> > why didn't you introduce class_migrate_pud?
> 
> Because there is no list to iterate through. 

i don't understand what you mean.
why you don't iterate pud, while you iterate pgdir and pmd?

YAMAMOTO Takashi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
