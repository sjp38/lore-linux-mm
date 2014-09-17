Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id EB3376B0038
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 07:42:19 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so62849wiv.8
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 04:42:19 -0700 (PDT)
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
        by mx.google.com with ESMTPS id jy2si28090178wjc.14.2014.09.17.04.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 04:42:18 -0700 (PDT)
Received: by mail-we0-f176.google.com with SMTP id q58so1272832wes.35
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 04:42:18 -0700 (PDT)
Date: Wed, 17 Sep 2014 14:42:15 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140917114214.GB30733@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <20140917102635.GA30733@minantech.com>
 <20140917112713.GB1273@potion.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20140917112713.GB1273@potion.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 17, 2014 at 01:27:14PM +0200, Radim Kr=C4=8Dm=C3=A1=C5=99 wrote:
> 2014-09-17 13:26+0300, Gleb Natapov:
> > For async_pf_execute() you do not need to even retry. Next guest's page=
 fault
> > will retry it for you.
>=20
> Wouldn't that be a waste of vmentries?
This is how it will work with or without this second gup. Page is not
mapped into a shadow page table on this path, it happens on a next fault.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
