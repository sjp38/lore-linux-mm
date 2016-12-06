Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 89F066B0253
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 14:27:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so37293856pgc.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 11:27:34 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v1si20629051plb.62.2016.12.06.11.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 11:27:33 -0800 (PST)
Subject: Re: [PATCH] mm: make transparent hugepage size public
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
 <877f7difx1.fsf@linux.vnet.ibm.com>
 <85c787f4-36ff-37fe-ff93-e42bad4b7c1e@intel.com>
 <20161206171905.n7qwvfb5sjxn3iif@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <db569a60-5dd1-b0a8-9fcb-6dd2106765ee@intel.com>
Date: Tue, 6 Dec 2016 11:27:28 -0800
MIME-Version: 1.0
In-Reply-To: <20161206171905.n7qwvfb5sjxn3iif@black.fi.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On 12/06/2016 09:19 AM, Kirill A. Shutemov wrote:
>>> > > We have in /proc/meminfo
>>> > > 
>>> > > Hugepagesize:       2048 kB
>>> > > 
>>> > > Does it makes it easy for application to find THP page size also there ?
>> > 
>> > Nope.  That's the default hugetlbfs page size.  Even on x86, that can be
>> > changed and _could_ be 1G.  If hugetlbfs is configured out, you also
>> > won't get this in meminfo.
> I think Aneesh propose to add one more line into the file.

Ahhh, ok...

Personally, I think Hugh did the right things.  There's no reason to
waste cycles sticking a number in meminfo that never changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
