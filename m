From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Thu, 31 May 2007 22:43:19 +0200
References: <1180467234.5067.52.camel@localhost> <1180637765.5091.153.camel@localhost> <20070531200644.GD10459@minantech.com>
In-Reply-To: <20070531200644.GD10459@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705312243.20242.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > Do I
> > > miss something here?
> > 
> > I think you do.  
> OK. It seems I missed the fact that VMA policy is completely ignored for
> pagecache backed files and only task policy is used. 

That's not correct. tmpfs is page cache backed and supports (even shared) VMA policy.
hugetlbfs used to too, but lost its ability, but will hopefully get it again.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
