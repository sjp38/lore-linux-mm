Date: Sat, 15 Apr 2006 09:06:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Swapless V2: Revise main migration logic
Message-Id: <20060415090639.dde469e8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0604140945320.18453@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
	<20060413235432.15398.23912.sendpatchset@schroedinger.engr.sgi.com>
	<20060414101959.d59ac82d.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604131832020.16220@schroedinger.engr.sgi.com>
	<20060414113455.15fd5162.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604140945320.18453@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Hi,
On Fri, 14 Apr 2006 09:48:25 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:
> > +/* write protected page under migration*/
> > +#define SWP_TYPE_MIGRATION_WP	(MAX_SWAPFILES - 1)
> > +/* write enabled migration type */
> > +#define SWP_TYPE_MIGRATION_WE	(MAX_SWAPFILES)
> 
> Could we call this SWP_TYPE_MIGRATION_READ / WRITE?
> 
ok, it looks better.

> > +	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
> > +	if (is_migration_entry_we(entry)) {
> is_write_migration_entry?
> 
> > +		pte = pte_mkwrite(pte);
> > +	}
> 
> No {} needed.
> 
> > -			entry = make_migration_entry(page);
> > +			if (pte_write(pteval))
> > +				entry = make_migration_entry(page, 1);
> > +			else
> > +				entry = make_migration_entry(page, 0);
> >  		}
> 
> entry = make_migration_entry(page, pte_write(pteval))
> 
> ?
Ah, O.K.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
