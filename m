Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 87C106B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:39:55 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2920109eak.2
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 00:39:54 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id p9si750842eew.139.2014.01.20.00.39.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 00:39:54 -0800 (PST)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 20 Jan 2014 08:39:53 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id CC3431B08061
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:39:15 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0K8ddsa983372
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:39:39 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0K8doKe016897
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 01:39:50 -0700
Date: Mon, 20 Jan 2014 09:39:48 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory
 areas
Message-ID: <20140120093948.0add11f4@lilie>
In-Reply-To: <902E09E6452B0E43903E4F2D568737AB0B9852BA@DFRE01.ent.ti.com>
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
	<52D538FD.8010907@ti.com>
	<20140114195225.078f810a@lilie>
	<902E09E6452B0E43903E4F2D568737AB0B9852BA@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Strashko, Grygorii" <grygorii.strashko@ti.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "daeseok.youn@gmail.com" <daeseok.youn@gmail.com>, "liuj97@gmail.com" <liuj97@gmail.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "Shilimkar,
 Santosh" <santosh.shilimkar@ti.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Am Fri, 17 Jan 2014 18:08:13 +0000
schrieb "Strashko, Grygorii" <grygorii.strashko@ti.com>:

Hello Grygorii,

> > The current patch seems to be overly complicated.
> > The following patch contains only the nomap functionality without
> > any cleanup and refactoring. I will post a V4 patch set which will
> > contain this patch.

please see the V4 patch set I've sent to the list. There you will
clearly see that nothing is changed. No API is broken by the patch.
The patch only adds functionality.
Everything that worked before keeps working as before without any
changes needed in any arch's code.

Kind regards

Philipp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
