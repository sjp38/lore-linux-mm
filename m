Message-ID: <48931AD1.6040904@linux-foundation.org>
Date: Fri, 01 Aug 2008 09:16:49 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
References: <1217452439.7676.26.camel@lts-notebook>	<4891C8BC.1020509@linux-foundation.org>	<1217515429.6507.7.camel@lts-notebook>	<489313AC.3080605@linux-foundation.org> <20080801100623.4aae3e37@bree.surriel.com>
In-Reply-To: <20080801100623.4aae3e37@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Fri, 01 Aug 2008 08:46:20 -0500
> Christoph Lameter <cl@linux-foundation.org> wrote:
> 
>> Yes I know and I think the rationale is not convincing if the justification
>> of the additional LRU is primarily for page migration.
> 
> Basically there are two alternatives:

I think we have sufficient reasons to have a second LRU (see my earlier mail)
just the text did not emphasize the right ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
