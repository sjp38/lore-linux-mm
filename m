Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A62336B034F
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 15:09:46 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id b202so351420926oii.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 12:09:46 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id y128si11819419oig.1.2016.12.20.12.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 12:09:46 -0800 (PST)
Received: by mail-oi0-x233.google.com with SMTP id w63so189458018oiw.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 12:09:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161220075942.GB496@quack2.suse.cz>
References: <20161212164708.23244-1-jack@suse.cz> <20161213115209.GG15362@quack2.suse.cz>
 <CAPcyv4giLyY8pWP09V5BmUM+sfGO-VJCtkfV6L-RFS+0XQsT9Q@mail.gmail.com>
 <CAPcyv4jqN+GkO7pL0QE0vM50MmqPZ1aD2G3YmziKvp+4+oh5gQ@mail.gmail.com>
 <20161219095623.GE17598@quack2.suse.cz> <CAPcyv4jjLg=Nyxusz5Hp8OaJ9fi0Xf6LHW37jgVbxKoOYHjNQw@mail.gmail.com>
 <20161220075942.GB496@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 20 Dec 2016 12:09:45 -0800
Message-ID: <CAPcyv4gYeQ+ZjJZU07Co5OHvgPsdU4vmYPOfUyMxJTqmMRktnw@mail.gmail.com>
Subject: Re: [PATCH 0/6 v3] dax: Page invalidation fixes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Mon, Dec 19, 2016 at 11:59 PM, Jan Kara <jack@suse.cz> wrote:
> On Mon 19-12-16 13:51:53, Dan Williams wrote:
[..]
> Yes, but I've accounted for that. Checking the libnvdimm-pending branch I
> see you missed "ext2: Return BH_New buffers for zeroed blocks" which was
> the first patch in the series. The subject is a slight misnomer since it is
> about setting IOMAP_F_NEW flag instead these days but still it is needed...
> Otherwise the DAX invalidation code would not propely invalidate zero pages
> in the radix tree in response to writes for ext2.

Ok, thanks. Updated libnvdimm-pending pushed out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
