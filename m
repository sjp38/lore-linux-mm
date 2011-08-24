Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B5DE86B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 09:55:51 -0400 (EDT)
Date: Wed, 24 Aug 2011 08:55:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2]slub: add a type for slab partial list position
In-Reply-To: <1314147472.29510.25.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1108240855290.24118@router.home>
References: <1314059823.29510.19.camel@sli10-conroe>  <alpine.DEB.2.00.1108231023470.21267@router.home> <1314147472.29510.25.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>

On Wed, 24 Aug 2011, Shaohua Li wrote:

> Subject: slub: explicitly document position of inserting slab to partial list

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
