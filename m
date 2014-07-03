Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 089F56B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:40:28 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id p9so107938lbv.40
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:40:28 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id qp9si6368784lbb.61.2014.07.03.05.40.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 05:40:27 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 3 Jul 2014 18:10:22 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B409BE0045
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 18:11:39 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s63Cff0G15204448
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 18:11:42 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s63CeHwa002475
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 18:10:18 +0530
Date: Thu, 3 Jul 2014 20:40:15 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: mm: slub: invalid memory access in setup_object
Message-ID: <20140703124015.GA17431@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <53AAFDF7.2010607@oracle.com>
 <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
 <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
 <20140702020454.GA6961@richard>
 <alpine.DEB.2.11.1407020918130.17773@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407020918130.17773@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Wed, Jul 02, 2014 at 09:20:20AM -0500, Christoph Lameter wrote:
>On Wed, 2 Jul 2014, Wei Yang wrote:
>
>> My patch is somewhat convoluted since I wanted to preserve the original logic
>> and make minimal change. And yes, it looks not that nice to audience.
>
>Well I was the author of the initial "convoluted" logic.
>
>> I feel a little hurt by this patch. What I found and worked is gone with this
>> patch.
>
>Ok how about giving this one additional revision. Maybe you can make the
>function even easier to read? F.e. the setting of the NULL pointer at the
>end of the loop is ugly.

Hi, Christoph

Here is my refined version, hope this is more friendly to the audience.
