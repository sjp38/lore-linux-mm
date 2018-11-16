Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC3436B09D1
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:51:02 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id m137-v6so28963807ita.9
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:51:02 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q203-v6si17726175itb.61.2018.11.16.05.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:51:02 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 1/5] mm: print more information about mapping in
 __dump_page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181116083020.20260-2-mhocko@kernel.org>
Date: Fri, 16 Nov 2018 06:50:52 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <F51AB111-E394-4F67-A5DD-2E7D854086DC@oracle.com>
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



> On Nov 16, 2018, at 1:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> __dump_page prints the mapping pointer but that is quite unhelpful
> for many reports because the pointer itself only helps to distinguish
> anon/ksm mappings from other ones (because of lowest bits
> set). Sometimes it would be much more helpful to know what kind of
> mapping that is actually and if we know this is a file mapping then also
> try to resolve the dentry name.

I really, really like this - the more information available in the dump
output, the easier it is to know where to start looking for the problem.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
