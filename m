Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD7E6B0035
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 04:49:25 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so7076146pbc.12
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 01:49:24 -0800 (PST)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id rx8si5094142pac.308.2014.01.13.01.49.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 01:49:23 -0800 (PST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 13 Jan 2014 19:46:28 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 325EF2CE8052
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:46:26 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0D9RSoK59441398
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:27:33 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0D9kKEx005289
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:46:20 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V4] powerpc: thp: Fix crash on mremap
In-Reply-To: <1389598587.4672.121.camel@pasglop>
References: <1389593064-32664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1389598587.4672.121.camel@pasglop>
Date: Mon, 13 Jan 2014 15:16:08 +0530
Message-ID: <87wqi42p0f.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, aarcange@redhat.com
Cc: paulus@samba.org, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Mon, 2014-01-13 at 11:34 +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patch fix the below crash
>
> Andrea, can you ack the generic bit please ?
>
> Thanks !

Kirill A. Shutemov did ack an earlier version

http://article.gmane.org/gmane.linux.kernel.mm/111368

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
