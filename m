Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7676B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:42:05 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id u188so21566578qkc.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:42:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z59si1723826qtc.147.2017.02.28.07.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:42:04 -0800 (PST)
Date: Tue, 28 Feb 2017 16:42:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fault in __do_fault
Message-ID: <20170228154201.GH5816@redhat.com>
References: <CACT4Y+YgntApw9WMLZwF_ncF4JQdA2FNHDpzM+8hb_FpCuuC_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YgntApw9WMLZwF_ncF4JQdA2FNHDpzM+8hb_FpCuuC_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, syzkaller <syzkaller@googlegroups.com>

Hello Dmitry,

On Tue, Feb 28, 2017 at 03:04:53PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> The following program triggers GPF in __do_fault:
> https://gist.githubusercontent.com/dvyukov/27345737fca18d92ef761e7fa08aec9b/raw/d99d02511d0bf9a8d6f6bd9c79d373a26924e974/gistfile1.txt

Can you verify this fix:
