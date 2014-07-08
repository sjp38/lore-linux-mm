Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B9E9F6B0037
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 21:34:39 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so6235988pdi.4
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 18:34:39 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id aw13si42336872pac.24.2014.07.07.18.34.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 18:34:38 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 8 Jul 2014 11:34:34 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 358E02CE8066
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 11:34:30 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s681HpL829884618
	for <linux-mm@kvack.org>; Tue, 8 Jul 2014 11:17:52 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s681YSTo030031
	for <linux-mm@kvack.org>; Tue, 8 Jul 2014 11:34:28 +1000
Date: Tue, 8 Jul 2014 09:34:26 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: mm: slub: invalid memory access in setup_object
Message-ID: <20140708013426.GA18392@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <53AAFDF7.2010607@oracle.com>
 <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
 <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
 <20140702020454.GA6961@richard>
 <alpine.DEB.2.11.1407020918130.17773@gentwo.org>
 <20140703124015.GA17431@richard>
 <alpine.DEB.2.11.1407070850510.21323@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407070850510.21323@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, Jul 07, 2014 at 08:51:08AM -0500, Christoph Lameter wrote:
>On Thu, 3 Jul 2014, Wei Yang wrote:
>
>> Here is my refined version, hope this is more friendly to the audience.
>
>Acked-by: Christoph Lameter <cl@linux.com>

Thanks. I am glad to work with you.

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
