Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50BD18D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 08:59:00 -0500 (EST)
Date: Wed, 9 Mar 2011 13:58:30 +0000
From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH R4 2/7] xen/balloon: HVM mode support
In-Reply-To: <20110308214636.GC27331@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103091356370.2968@kaball-desktop>
References: <20110308214636.GC27331@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: Ian Campbell <Ian.Campbell@eu.citrix.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 8 Mar 2011, Daniel Kiper wrote:
> HVM mode support.

I have already a patch in linux-next to do this, please give a look at
"xen: make the ballon driver work for hvm domains":

git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git linux-next

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
