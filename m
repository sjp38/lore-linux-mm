Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D81616B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 12:20:53 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w23-v6so6649731pgv.1
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 09:20:53 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 6-v6si14980060pgg.366.2018.07.02.09.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 09:20:50 -0700 (PDT)
Subject: Re: [PATCH v3 0/2] sparse_init rewrite
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <de99ae79-8d68-e8d6-5243-085fd106e1e5@intel.com>
Date: Mon, 2 Jul 2018 09:20:40 -0700
MIME-Version: 1.0
In-Reply-To: <20180702020417.21281-1-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/01/2018 07:04 PM, Pavel Tatashin wrote:
>  include/linux/mm.h  |   9 +-
>  mm/sparse-vmemmap.c |  44 ++++---
>  mm/sparse.c         | 279 +++++++++++++++-----------------------------
>  3 files changed, 125 insertions(+), 207 deletions(-)

FWIW, I'm not a fan of rewrites, but this is an awful lot of code to remove.

I assume from all the back-and-forth, you have another version
forthcoming.  I'll take a close look through that one.
