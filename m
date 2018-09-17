Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0713E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 17:10:03 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4-v6so8221610plk.7
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 14:10:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v66-v6si16212733pfb.368.2018.09.17.14.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 14:10:01 -0700 (PDT)
Date: Mon, 17 Sep 2018 23:09:55 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: Patch "x86/kexec: Allocate 8k PGDs for PTI" has been added to
 the 3.18-stable tree
Message-ID: <20180917210955.ucnsxd4bem452kxt@suse.de>
References: <1537177617126129@kroah.com>
 <alpine.LSU.2.11.1809171213560.1601@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1809171213560.1601@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: gregkh@linuxfoundation.org, 1532533683-5988-4-git-send-email-joro@8bytes.org, David.Laight@aculab.com, aarcange@redhat.com, acme@kernel.org, alexander.levin@microsoft.com, alexander.shishkin@linux.intel.com, aliguori@amazon.com, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, daniel.gruss@iaik.tugraz.at, dave.hansen@intel.com, dhgutteridge@sympatico.ca, dvlasenk@redhat.com, eduval@amazon.com, hpa@zytor.com, jgross@suse.com, jkosina@suse.cz, jolsa@redhat.comjoro@8bytes.org, jpoimboe@redhat.com, keescook@google.com, linux-mm@kvack.org, llong@redhat.com, luto@kernel.org, namhyung@kernel.org, pavel@ucw.cz, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com, stable-commits@vger.kernel.org, stable@vger.kernel.org

On Mon, Sep 17, 2018 at 12:33:47PM -0700, Hugh Dickins wrote:
> In several of the recent stable trees, I think this will not do any
> actual harm; but it looks as if it will prevent relevant x86-32 configs
> from building on 3.18 (I see no definition of PGD_ALLOCATION_ORDER in
> linux-3.18.y - you preferred not to have any PTI in that tree), and I
> haven't checked whether its definition in older backports will build
> correctly here or not.

Right, thanks for pointing that out. I should have added a Fixes:-tag to
the patch to make clear what the fix it for, sorry for that.


	Joerg
