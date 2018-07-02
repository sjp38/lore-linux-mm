Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F00196B0007
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 14:48:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d66-v6so14930061qkf.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:48:00 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y3-v6si531416qkc.401.2018.07.02.11.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 11:48:00 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62IhcJP045827
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 18:47:58 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2jx1tnwp2a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 18:47:58 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w62Ilv6l032734
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 18:47:57 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w62IluGI025327
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 18:47:57 GMT
Received: by mail-oi0-f47.google.com with SMTP id r16-v6so17796410oie.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:47:56 -0700 (PDT)
MIME-Version: 1.0
References: <20180702154325.12196-1-osalvador@techadventures.net>
In-Reply-To: <20180702154325.12196-1-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 14:47:20 -0400
Message-ID: <CAGM2reZz3=OM7W_VbCGgnAMumo+AiPaG7sGUaichG_QNngYKsg@mail.gmail.com>
Subject: Re: [PATCH] mm/sparse: Make sparse_init_one_section void and remove check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, bhe@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Mon, Jul 2, 2018 at 11:43 AM <osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> sparse_init_one_section() is being called from two sites:
> sparse_init() and sparse_add_one_section().
> The former calls it from a for_each_present_section_nr() loop,
> and the latter marks the section as present before calling it.
> This means that when sparse_init_one_section() gets called, we already know
> that the section is present.
> So there is no point to double check that in the function.
>
> This removes the check and makes the function void.
>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Thank you Oscar.

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

> ---
>  mm/sparse.c | 12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
