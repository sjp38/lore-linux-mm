Message-ID: <43715266.5080900@jp.fujitsu.com>
Date: Wed, 09 Nov 2005 10:35:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] Direct Migration V2: upgrade MPOL_MF_MOVE and sys_migrate_pages()
References: <20051108210246.31330.61756.sendpatchset@schroedinger.engr.sgi.com> <20051108210402.31330.19167.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051108210402.31330.19167.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, torvalds@osdl.org, Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Magnus Damm <magnus.damm@gmail.com>, Paul Jackson <pj@sgi.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> +	err = migrate_pages(pagelist, &newlist, &moved, &failed);
> +
> +	putback_lru_pages(&moved);	/* Call release pages instead ?? */
> +
> +	if (err >= 0 && list_empty(&newlist) && !list_empty(pagelist))
> +		goto redo;


Here, list_empty(&newlist) is needed ?
For checking permanent failure case, list_empty(&failed) looks better.

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
