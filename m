In-Reply-To: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
References: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Message-Id: <46434BBD-7656-41B1-BED0-3A3E212032B5@kernel.crashing.org>
Content-Transfer-Encoding: 7bit
From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/3] Add remove_memory() for ppc64
Date: Thu, 1 Nov 2007 01:26:48 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Oct 31, 2007, at 11:49 AM, Badari Pulavarty wrote:

> Supply arch specific remove_memory() for PPC64. There is nothing
> ppc specific code here and its exactly same as ia64 version.
> For now, lets keep it arch specific - so each arch can add
> its own special things if needed.
>
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> ---

What's ppc64 specific about these patches?

- k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
