Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6E0116B13F3
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 09:46:28 -0500 (EST)
Date: Wed, 8 Feb 2012 08:46:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc PATCH]slub: per cpu partial statistics change
In-Reply-To: <1328676290.12669.431.camel@debian>
Message-ID: <alpine.DEB.2.00.1202080846030.29839@router.home>
References: <1328256695.12669.24.camel@debian>  <alpine.DEB.2.00.1202030920060.2420@router.home>  <4F2C824E.8080501@intel.com>  <alpine.DEB.2.00.1202060858510.393@router.home>  <1328591165.12669.168.camel@debian>  <alpine.DEB.2.00.1202070910320.29500@router.home>
 <1328676290.12669.431.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 8 Feb 2012, Alex,Shi wrote:

> > A bit long I think. CPU_PARTIAL_DRAIN?
>
> Yes. it is more meaningful. :)
> Patch change here.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
