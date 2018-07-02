Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFA816B000A
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:47:05 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d70-v6so8323497itd.1
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:47:05 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u77-v6si972906ita.128.2018.07.02.10.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 10:47:03 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62HiMrY001813
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 17:47:02 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2jx1tnwfea-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 17:47:02 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w62Hl1Fl001207
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 17:47:02 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w62Hl1Nv001199
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 17:47:01 GMT
Received: by mail-oi0-f45.google.com with SMTP id i12-v6so13541422oik.2
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:47:01 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com> <de99ae79-8d68-e8d6-5243-085fd106e1e5@intel.com>
In-Reply-To: <de99ae79-8d68-e8d6-5243-085fd106e1e5@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 13:46:25 -0400
Message-ID: <CAGM2reYVkvVPgj+_upEdpjUL5noS=0ObGxnxXH3gAz+cJosEjA@mail.gmail.com>
Subject: Re: [PATCH v3 0/2] sparse_init rewrite
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Mon, Jul 2, 2018 at 12:20 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 07/01/2018 07:04 PM, Pavel Tatashin wrote:
> >  include/linux/mm.h  |   9 +-
> >  mm/sparse-vmemmap.c |  44 ++++---
> >  mm/sparse.c         | 279 +++++++++++++++-----------------------------
> >  3 files changed, 125 insertions(+), 207 deletions(-)
>
> FWIW, I'm not a fan of rewrites, but this is an awful lot of code to remove.
>
> I assume from all the back-and-forth, you have another version
> forthcoming.  I'll take a close look through that one.

The removed code is a benefit, but once you review it, you will see
that it was necessary to re-write in order to get rid of the temporary
buffers. Please review the current version. The only change that is
going to be in the next version is added "nid" to pr_err() in
sparse_init_nid() for more detailed error.

Thank you,
Pavel
