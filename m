Message-ID: <48932E91.9050208@linux-foundation.org>
Date: Fri, 01 Aug 2008 10:41:05 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
References: <1217452439.7676.26.camel@lts-notebook>	 <4891C8BC.1020509@linux-foundation.org>	 <1217515429.6507.7.camel@lts-notebook>	 <489313AC.3080605@linux-foundation.org>	 <20080801100623.4aae3e37@bree.surriel.com>	 <48931AD1.6040904@linux-foundation.org> <1217601369.6232.16.camel@lts-notebook>
In-Reply-To: <1217601369.6232.16.camel@lts-notebook>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:

> Really?  You think it would be OK to leave maybe gigabytes of mlocked
> pages non-migratable?  This would prevent defrag, hotplug, and cpuset

Whatever made you think that I would have that view?

I said that we have sufficient reasons I just do not think these reasons were
given in the document. The main reason was not page migration.

> The rationale that Rik mentioned--common handling, as much as
> possible--was the second reason mentioned in the text.  Perhaps my
> wording could use some rework/clarification.

Yes please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
