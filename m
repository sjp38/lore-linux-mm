Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BD8C06B01CC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 02:04:32 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5H5vnqq001686
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 23:57:49 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5H64Vlr174880
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 00:04:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5H64VGv024041
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 00:04:31 -0600
Date: Thu, 17 Jun 2010 11:34:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100617060428.GH4306@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100614125010.GU5191@balbir.in.ibm.com>
 <4C162846.7030303@redhat.com>
 <1276529596.6437.7216.camel@nimitz>
 <4C164E63.2020204@redhat.com>
 <1276530932.6437.7259.camel@nimitz>
 <4C1659F8.3090300@redhat.com>
 <1276538293.6437.7528.camel@nimitz>
 <4C1726C4.8050300@redhat.com>
 <1276613249.6437.11516.camel@nimitz>
 <4C18B7D6.5070300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C18B7D6.5070300@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-16 14:39:02]:

> >We're talking about an environment which we're always trying to
> >optimize.  Imagine that we're always trying to consolidate guests on to
> >smaller numbers of hosts.  We're effectively in a state where we
> >_always_ want new guests.
> 
> If this came at no cost to the guests, you'd be right.  But at some
> point guest performance will be hit by this, so the advantage gained
> from freeing memory will be balanced by the disadvantage.
> 
> Also, memory is not the only resource.  At some point you become cpu
> bound; at that point freeing memory doesn't help and in fact may
> increase your cpu load.
>

We'll probably need control over other resources as well, but IMHO
memory is the most precious because it is non-renewable. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
