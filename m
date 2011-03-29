Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7C19D8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 12:29:08 -0400 (EDT)
Message-ID: <4D92087D.3090600@tycho.nsa.gov>
Date: Tue, 29 Mar 2011 12:27:41 -0400
From: Daniel De Graaf <dgdegra@tycho.nsa.gov>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] xen/balloon: Cleanups and fixes for 2.6.40
References: <20110328093128.GE13826@router-fw-old.local.net-space.pl> <1301409001.18413.11.camel@zakaz.uk.xensource.com>
In-Reply-To: <1301409001.18413.11.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/29/2011 10:30 AM, Ian Campbell wrote:
> On Mon, 2011-03-28 at 10:31 +0100, Daniel Kiper wrote:
>> Hi,
>>
>> Full list of cleanups/fixes:
>>   - xen/balloon: Use PageHighMem() for high memory page detection,
>>   - xen/balloon: Simplify HVM integration,
>>   - xen/balloon: Clarify credit calculation,
>>   - xen/balloon: Move dec_totalhigh_pages() from __balloon_append() to balloon_append().
>>
>> Those patches applies to latest Linus' git tree
>> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git).
>> They are required by latest memory hotplug support for Xen balloon
>> driver patch which will be sent soon.
> 
> This series looks sane to me, so:
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> 
> CC'ing Daniel De Graaf though since he has been working on the balloon
> driver recently as well.
> 
> Ian.
> 
The series also looks fine to me.

-- 
Daniel De Graaf
National Security Agency

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
