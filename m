Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A88F82F64
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 07:14:56 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vp2so27122378pab.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 04:14:56 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w20si8441255pfj.166.2016.09.07.04.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 04:14:55 -0700 (PDT)
Date: Wed, 7 Sep 2016 14:14:52 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: regression: lk 4.8 + !CONFIG_SHMEM + shmat() = oops
Message-ID: <20160907111452.GA138665@black.fi.intel.com>
References: <58cdb20c-8195-ca05-3700-3ab37a031848@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58cdb20c-8195-ca05-3700-3ab37a031848@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, Aug 30, 2016 at 01:52:11PM -0400, Tony Battersby wrote:
> The following commit is causing shmat() to oops when CONFIG_SHMEM is
> not set:
> 
> c01d5b300774 ("shmem: get_unmapped_area align huge page")
> 
> Here is the oops:
> 
> BUG: unable to handle kernel NULL pointer dereference at           (null)

Sorry, for delay. This should fix the issue:
