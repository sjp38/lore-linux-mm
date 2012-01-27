Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A90536B0074
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 22:33:25 -0500 (EST)
Message-ID: <4F221AFE.6070108@redhat.com>
Date: Thu, 26 Jan 2012 22:33:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default> <4F218D36.2060308@linux.vnet.ibm.com> <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default> <20120126163150.31a8688f.akpm@linux-foundation.org> <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default> <20120126171548.2c85dd44.akpm@linux-foundation.org> <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
In-Reply-To: <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>

On 01/26/2012 09:43 PM, Dan Magenheimer wrote:

> Maybe the Active page bit could be overloaded with some minor
> rewriting?  IOW, perhaps the Active bit could be ignored when
> the page is moved to the inactive LRU?  (Confusing I know, but I am
> just brainstorming...)

The PG_referenced bit is already overloaded.  We keep
the bit set when we move a page from the active to the
inactive list, so a page that was previously active
only needs to be referenced once to become active again.

The LRU bits (PG_lru, PG_active, etc) are needed to
figure out which LRU list the page is on.  I don't
think we can overload those...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
