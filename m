Date: Fri, 28 Apr 2006 16:30:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] page migration: Drop nr_refs parameter
Message-Id: <20060428163033.4fa4863a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060428060317.30257.27066.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
	<20060428060317.30257.27066.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 27 Apr 2006 23:03:18 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> page migration: Drop nr_refs parameter from migrate_page_remove_references()
> 
> The nr_refs parameter is not really useful since the number of remaining
> references is always
> 
> 1 for anonymous pages without a mapping
> 2 for pages with a mapping
> 3 for pages with a mapping and PagePrivate set.
> 
Then, could you add this comment to migrate_page_remove_references
(renamed as migrate_page_move_mapping) ?

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
