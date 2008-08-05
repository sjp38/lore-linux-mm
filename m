Message-ID: <489888FB.9060401@linux-foundation.org>
Date: Tue, 05 Aug 2008 12:08:11 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC:Patch: 000/008](memory hotplug) rough idea of pgdat removing
References: <20080802090335.D6C8.E1E9C6FF@jp.fujitsu.com> <4897032E.5020601@linux-foundation.org> <20080805150434.BF32.E1E9C6FF@jp.fujitsu.com> <20080805111450.GE20243@csn.ul.ie>
In-Reply-To: <20080805111450.GE20243@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> Maybe I am missing something, but what is wrong with stop_machine during
> memory hot-remove?

Reclaim can sleep while going down a zonelist. There would need to be some
form of synchronization to avoid removing a zone from the zonelist that we are
just scanning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
