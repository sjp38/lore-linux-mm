Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id AC3DC6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:50:04 -0400 (EDT)
Message-ID: <520BFB87.6050207@sr71.net>
Date: Wed, 14 Aug 2013 14:49:59 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com> <520BECDF.8060501@sr71.net> <20130814211454.GA17423@variantweb.net> <520BF88C.6060202@linux.vnet.ibm.com>
In-Reply-To: <520BF88C.6060202@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2013 02:37 PM, Cody P Schafer wrote:
> Also, I'd expect userspace tools might use readdir() to find out what
> memory blocks a system has (unless they just stat("memory0"),
> stat("memory1")...). I don't think filesystem tricks (at least within
> sysfs) are going to let this magically be solved without breaking the
> userspace API.

sysfs files are probably a bit too tied to kobjects to make this work
easily in practice.  It would probably need to be a new filesystem, imnho.

But, there's nothing to keep you from creating dentries for all of the
memory blocks if someone _does_ a readdir().  It'll suck, of course, but
it's at least compatible with what's there.  You could also 'chmod -x'
it to make it more obvious that folks shouldn't be poking around in
there, although it won't keep them from ls'ing.  If you're concerned
about resource consumption, we could also just make the directory
unreadable to everyone but root.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
